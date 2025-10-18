import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../datasources/auth_local_datasource.dart';
import '../models/auth_response_model.dart';

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences _prefs;

  AuthLocalDataSourceImpl(this._prefs);

  @override
  Future<void> saveAuthData(AuthResponseModel response) async {
    await _prefs.setString('auth_data', jsonEncode(response.toJson()));
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
  }

  @override
  Future<void> saveToken(String token) async {
    await _prefs.setString('auth_token', token);
  }

  @override
  Future<String?> getToken() async {
    return _prefs.getString('auth_token');
  }

  @override
  Future<void> clearToken() async {
    await _prefs.remove('auth_token');
  }
}
