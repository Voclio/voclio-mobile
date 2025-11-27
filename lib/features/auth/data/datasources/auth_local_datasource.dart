import '../models/auth_response_model.dart';

abstract class AuthLocalDataSource {
  Future<void> saveAuthData(AuthResponseModel response);
  Future<AuthResponseModel?> getAuthData();
  Future<void> clearAuthData();
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> clearToken();
}
