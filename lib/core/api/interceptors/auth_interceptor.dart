import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../api_endpoints.dart';
import 'dart:async';

class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;
  final Dio _dio;
  
  // Prevent concurrent token refreshes
  static Future<String?>? _refreshFuture;
  static bool _isRefreshing = false;
  
  // Token refresh buffer - refresh 5 minutes before expiration
  static const int _tokenRefreshBufferSeconds = 300; // 5 minutes
  
  // Maximum retry attempts for failed requests
  static const int _maxRetryAttempts = 3;

  static const List<String> _publicEndpoints = [
    '/auth/login',
    '/auth/register',
    '/auth/google',
    '/auth/facebook',
    '/auth/refresh-token',
    '/auth/reset-password',
    '/auth/forgot-password',
    '/auth/send-otp',
    '/auth/verify-otp',
    '/auth/resend-otp',
    '/health',
    '/',
  ];

  AuthInterceptor(this._storage, this._dio);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth for public endpoints
    if (_publicEndpoints.contains(options.path) ||
        options.path == ApiEndpoints.refreshToken) {
      return handler.next(options);
    }

    try {
      // Get current token with timeout
      final token = await _storage.read(key: 'access_token').timeout(
        const Duration(seconds: 2),
        onTimeout: () => null,
      );
      
      // Check if token exists and is valid
      if (token == null || token.isEmpty) {
        // No token, proceed without auth (let server handle it)
        return handler.next(options);
      }

      // Get expiration with timeout
      final expiresAtString = await _storage.read(key: 'token_expires_at').timeout(
        const Duration(seconds: 1),
        onTimeout: () => null,
      );

      // Check if token is expired or expiring soon (proactive refresh)
      bool needsRefresh = false;
      if (expiresAtString != null) {
        final expiresAt = DateTime.tryParse(expiresAtString);
        if (expiresAt != null) {
          // Refresh if token will expire within the buffer time (proactive refresh)
          final bufferTime = Duration(seconds: _tokenRefreshBufferSeconds);
          final refreshThreshold = expiresAt.subtract(bufferTime);
          needsRefresh = DateTime.now().isAfter(refreshThreshold);
        }
      } else {
        // No expiration stored, refresh to be safe
        needsRefresh = true;
      }

      // Refresh token if needed
      if (needsRefresh) {
        final refreshedToken = await _refreshAccessToken();
        if (refreshedToken != null) {
          options.headers['Authorization'] = 'Bearer $refreshedToken';
        } else {
          // Refresh failed, use existing token anyway
          options.headers['Authorization'] = 'Bearer $token';
        }
      } else {
        // Use existing token
        options.headers['Authorization'] = 'Bearer $token';
      }

      return handler.next(options);
    } catch (e) {
      // Any error in token handling, proceed without auth
      return handler.next(options);
    }
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Skip 401 handling for public endpoints
    if (_publicEndpoints.contains(err.requestOptions.path)) {
      return handler.next(err);
    }

    // Handle 401 Unauthorized - Token expired or invalid
    if (err.response?.statusCode == 401) {
      try {
        // Check retry count (prevent infinite loop)
        final retryCount = (err.requestOptions.extra['_retryCount'] as int?) ?? 0;
        if (retryCount >= _maxRetryAttempts) {
          // Max retries reached, clear tokens and fail
          await _clearTokens();
          return handler.next(err);
        }

        // Try to refresh token
        final newAccessToken = await _refreshAccessToken();
        if (newAccessToken != null && newAccessToken.isNotEmpty) {
          // Retry the original request with new token
          final originalRequest = err.requestOptions;
          originalRequest.headers['Authorization'] = 'Bearer $newAccessToken';
          originalRequest.extra['_retryCount'] = retryCount + 1;

          try {
            // Add a small delay before retry to prevent rapid retries
            await Future.delayed(const Duration(milliseconds: 100));
            final retryResponse = await _dio.fetch(originalRequest);
            return handler.resolve(retryResponse);
          } on DioException catch (retryError) {
            // If retry fails with 401 again, don't clear tokens yet, let it retry
            if (retryError.response?.statusCode == 401 && retryCount < _maxRetryAttempts - 1) {
              // Recursive handling will occur
              return handler.next(retryError);
            }
            // Other errors or max retries, clear tokens
            await _clearTokens();
            return handler.next(retryError);
          }
        } else {
          // Refresh failed, clear tokens
          await _clearTokens();
        }
      } catch (e) {
        // Any error during refresh, clear tokens
        await _clearTokens();
      }
    }

    return handler.next(err);
  }

  Future<String?> _refreshAccessToken() async {
    // If already refreshing, wait for existing refresh to complete
    if (_isRefreshing && _refreshFuture != null) {
      return await _refreshFuture;
    }

    // Start new refresh
    _isRefreshing = true;
    _refreshFuture = _performRefresh();

    try {
      final result = await _refreshFuture;
      return result;
    } finally {
      _isRefreshing = false;
      _refreshFuture = null;
    }
  }

  Future<String?> _performRefresh() async {
    try {
      final refreshToken = await _storage.read(key: 'refresh_token');
      
      // Validate refresh token exists
      if (refreshToken == null || refreshToken.isEmpty) {
        await _clearTokens();
        return null;
      }

      // Call refresh endpoint with timeout
      final response = await _dio.post(
        ApiEndpoints.refreshToken,
        data: {'refresh_token': refreshToken},
        options: Options(
          headers: {'Authorization': null},
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw TimeoutException('Token refresh timed out'),
      );

      // Validate response
      if (response.statusCode != 200 || response.data == null) {
        await _clearTokens();
        return null;
      }

      // Parse response
      final data = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};
      
      final payload = data['data'] is Map<String, dynamic>
          ? data['data'] as Map<String, dynamic>
          : data;

      final tokens = payload['tokens'] is Map<String, dynamic>
          ? payload['tokens'] as Map<String, dynamic>
          : payload;

      final newAccessToken =
          (tokens['access_token'] ?? tokens['token'] ?? '').toString().trim();
      final newRefreshToken =
          (tokens['refresh_token'] ?? tokens['refreshToken'] ?? '').toString().trim();

      // Validate tokens
      if (newAccessToken.isEmpty) {
        await _clearTokens();
        return null;
      }

      // Save new tokens
      await _storage.write(key: 'access_token', value: newAccessToken);
      
      // Only update refresh token if a new one was provided
      if (newRefreshToken.isNotEmpty) {
        await _storage.write(key: 'refresh_token', value: newRefreshToken);
      }

      // Calculate and save expiration
      // Backend provides expires_in in seconds, use a generous default (7 days) if not provided
      final expiresIn = tokens['expires_in'] is int
          ? tokens['expires_in'] as int
          : int.tryParse(tokens['expires_in']?.toString() ?? '') ?? 604800; // 7 days default
      
      final expiresAt = DateTime.now().add(
        Duration(seconds: expiresIn),
      );
      
      await _storage.write(
        key: 'token_expires_at',
        value: expiresAt.toIso8601String(),
      );

      return newAccessToken;
    } on DioException catch (e) {
      // Handle specific errors
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        // Refresh token is invalid or expired
        await _clearTokens();
      }
      return null;
    } catch (e) {
      // Don't clear tokens for network/timeout errors - might be temporary
      return null;
    }
  }

  Future<void> _clearTokens() async {
    try {
      await _storage.delete(key: 'access_token');
      await _storage.delete(key: 'refresh_token');
      await _storage.delete(key: 'token_expires_at');
    } catch (_) {
      // Ignore errors during cleanup
    }
  }
}
