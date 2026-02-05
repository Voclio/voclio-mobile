import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../datasources/auth_local_datasource.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences _prefs;
  final FlutterSecureStorage _storage;

  AuthLocalDataSourceImpl({
    required SharedPreferences prefs,
    required FlutterSecureStorage storage,
  }) : _prefs = prefs,
       _storage = storage;

  @override
  Future<void> saveAuthData(AuthResponseModel response) async {
    // Save User Data to SharedPreferences
    UserModel userModel = UserModel.fromEntity(response.user);

    // If refresh response doesn't include user data, keep existing cached user
    if ((userModel.email.isEmpty && userModel.name == 'Unknown User') ||
        userModel.id.isEmpty) {
      final cachedUserString = _prefs.getString('auth_user');
      if (cachedUserString != null) {
        try {
          final cachedUserJson = jsonDecode(cachedUserString);
          userModel = UserModel.fromJson(cachedUserJson);
        } catch (_) {}
      }
    }
    await _prefs.setString('auth_user', jsonEncode(userModel.toJson()));

    // Save Tokens to Secure Storage
    await _storage.write(key: 'access_token', value: response.token);
    await _storage.write(key: 'refresh_token', value: response.refreshToken);

    // Save token expiration time
    await _storage.write(
      key: 'token_expires_at',
      value: response.expiresAt.toIso8601String(),
    );
  }

  @override
  Future<AuthResponseModel?> getAuthData() async {
    try {
      final userString = _prefs.getString('auth_user');
      
      // Read tokens with timeout to prevent hanging
      final accessToken = await _storage.read(key: 'access_token').timeout(
        const Duration(seconds: 2),
        onTimeout: () => null,
      );
      final refreshToken = await _storage.read(key: 'refresh_token').timeout(
        const Duration(seconds: 2),
        onTimeout: () => null,
      );
      final expiresAtString = await _storage.read(key: 'token_expires_at').timeout(
        const Duration(seconds: 1),
        onTimeout: () => null,
      );

      // Validate all required data exists
      if (userString == null || 
          accessToken == null || 
          refreshToken == null ||
          accessToken.isEmpty ||
          refreshToken.isEmpty) {
        // Incomplete data, clear everything
        await clearAuthData();
        return null;
      }

      // Parse user data
      Map<String, dynamic> userJson;
      try {
        userJson = jsonDecode(userString);
      } catch (e) {
        // Corrupted user data, clear everything
        await clearAuthData();
        return null;
      }

      // Validate user data has required fields
      if (userJson['email'] == null || userJson['id'] == null) {
        await clearAuthData();
        return null;
      }

      // Calculate expires_in from persisted expiration time
      int expiresIn = 604800; // Default 7 days
      DateTime? expiresAt;
      
      if (expiresAtString != null) {
        expiresAt = DateTime.tryParse(expiresAtString);
        if (expiresAt != null) {
          expiresIn = expiresAt.difference(DateTime.now()).inSeconds;
          if (expiresIn < 0) {
            expiresIn = 0; // Token expired
          }
        }
      }

      // Build response model
      return AuthResponseModel.fromJson({
        'data': {
          'user': userJson,
          'tokens': {
            'access_token': accessToken,
            'refresh_token': refreshToken,
            'expires_in': expiresIn,
          },
        },
      });
    } catch (e) {
      // Any error, clear cache and return null
      await clearAuthData();
      return null;
    }
  }

  @override
  Future<void> clearAuthData() async {
    try {
      await _prefs.remove('auth_user');
    } catch (_) {}
    
    try {
      await _storage.delete(key: 'access_token');
    } catch (_) {}
    
    try {
      await _storage.delete(key: 'refresh_token');
    } catch (_) {}
    
    try {
      await _storage.delete(key: 'token_expires_at');
    } catch (_) {}
  }

  @override
  Future<void> saveToken(String token) async {
    await _storage.write(key: 'access_token', value: token);
  }

  @override
  Future<String?> getToken() async {
    return await _storage.read(key: 'access_token');
  }

  @override
  Future<void> clearToken() async {
    await _storage.delete(key: 'access_token');
  }
}
