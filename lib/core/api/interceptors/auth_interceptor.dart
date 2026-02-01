import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;
  final Dio _dio;

  static const List<String> _publicEndpoints = [
    '/auth/login',
    '/auth/register',
    '/auth/google',
    '/auth/facebook',
    '/auth/refresh-token',
    '/auth/reset-password',
    '/health',
    '/',
  ];

  AuthInterceptor(this._storage, this._dio);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (_publicEndpoints.contains(options.path)) {
      return handler.next(options);
    }

    // Add Bearer token to headers
    final token = await _storage.read(key: 'access_token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    return handler.next(options);
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

    // Handle 401 Unauthorized - Token expired
    if (err.response?.statusCode == 401) {
      try {
        // Try to refresh the token
        final refreshToken = await _storage.read(key: 'refresh_token');

        if (refreshToken != null) {
          final response = await _dio.post(
            '/auth/refresh-token',
            data: {'refresh_token': refreshToken},
            options: Options(
              headers: {'Authorization': null}, // No auth for refresh
            ),
          );

          if (response.statusCode == 200) {
            final newAccessToken =
                response.data['data']['tokens']['access_token'];
            final newRefreshToken =
                response.data['data']['tokens']['refresh_token'];

            // Save new tokens
            await _storage.write(key: 'access_token', value: newAccessToken);
            await _storage.write(key: 'refresh_token', value: newRefreshToken);

            // Retry the original request with new token
            final originalRequest = err.requestOptions;
            originalRequest.headers['Authorization'] = 'Bearer $newAccessToken';

            final retryResponse = await _dio.fetch(originalRequest);
            return handler.resolve(retryResponse);
          }
        }
      } catch (e) {
        // Refresh failed - logout user
        await _storage.deleteAll();
        // Navigate to login screen (handled in UI layer)
      }
    }

    return handler.next(err);
  }
}
