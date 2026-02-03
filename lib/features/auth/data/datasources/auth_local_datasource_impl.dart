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
    final userModel = UserModel.fromEntity(response.user);
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
      final accessToken = await _storage.read(key: 'access_token');
      final refreshToken = await _storage.read(key: 'refresh_token');
      final expiresAtString = await _storage.read(key: 'token_expires_at');

      if (userString != null && accessToken != null && refreshToken != null) {
        final userJson = jsonDecode(userString);

        // Calculate expires_in from persisted expiration time
        int expiresIn = 86400; // Default 24 hours
        if (expiresAtString != null) {
          final expiresAt = DateTime.tryParse(expiresAtString);
          if (expiresAt != null) {
            expiresIn = expiresAt.difference(DateTime.now()).inSeconds;
            if (expiresIn < 0) expiresIn = 0; // Token expired
          }
        }

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
      }
    } catch (e) {
      await clearAuthData();
    }
    return null;
  }

  @override
  Future<void> clearAuthData() async {
    await _prefs.remove('auth_user');
    await _storage.deleteAll();
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
