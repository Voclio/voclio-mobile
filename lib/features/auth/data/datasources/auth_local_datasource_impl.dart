import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../datasources/auth_local_datasource.dart';
import '../models/auth_response_model.dart';

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences _prefs;
  final FlutterSecureStorage _secureStorage;

  AuthLocalDataSourceImpl(this._prefs, this._secureStorage);

  @override
  Future<void> saveAuthData(AuthResponseModel response) async {
    await _prefs.setString('auth_data', jsonEncode(response.toJson()));
    // Save tokens securely for the AuthInterceptor
    await _secureStorage.write(key: 'access_token', value: response.token);
    await _secureStorage.write(
      key: 'refresh_token',
      value: response.refreshToken,
    );
  }

  @override
  Future<AuthResponseModel?> getAuthData() async {
    final authData = _prefs.getString('auth_data');
    if (authData != null) {
      try {
        final Map<String, dynamic> json = jsonDecode(authData);
        return AuthResponseModel.fromJson(json);
      } catch (e) {
        // If parsing fails, clear the corrupted data
        await clearAuthData();
        return null;
      }
    }
    return null;
  }

  @override
  Future<void> clearAuthData() async {
    await _prefs.remove('auth_data');
    await _secureStorage.delete(key: 'access_token');
    await _secureStorage.delete(key: 'refresh_token');
  }

  @override
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: 'access_token', value: token);
  }

  @override
  Future<String?> getToken() async {
    return await _secureStorage.read(key: 'access_token');
  }

  @override
  Future<void> clearToken() async {
    await _secureStorage.delete(key: 'access_token');
  }
}
