import '../models/auth_request_model.dart';
import '../models/auth_response_model.dart';
import '../models/otp_request_model.dart';
import '../models/otp_response_model.dart';
import '../../domain/entities/otp_request.dart';
import 'package:voclio_app/core/api/api_client.dart';
import 'package:voclio_app/core/api/api_endpoints.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login(AuthRequestModel request);
  Future<AuthResponseModel> register(AuthRequestModel request);
  Future<OTPResponseModel> sendOTP(String email, OTPType type);
  Future<OTPResponseModel> verifyOTP(OTPRequestModel request);
  Future<void> forgotPassword(String email);
  Future<void> resetPassword(String email, String newPassword, String otp);
  Future<void> logout();
  Future<AuthResponseModel> refreshToken(String refreshToken);
  Future<String> googleSignIn();
  Future<String> facebookSignIn();
  Future<void> changePassword(String currentPassword, String newPassword);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<AuthResponseModel> login(AuthRequestModel request) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.login,
        data: request.toJson(),
      );
      return AuthResponseModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  @override
  Future<AuthResponseModel> register(AuthRequestModel request) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.register,
        data: request.toJson(),
      );
      return AuthResponseModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  @override
  Future<OTPResponseModel> sendOTP(String email, OTPType type) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.sendOtp,
        data: {'email': email, 'type': type.toString().split('.').last},
      );
      return OTPResponseModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Send OTP failed: $e');
    }
  }

  @override
  Future<OTPResponseModel> verifyOTP(OTPRequestModel request) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.verifyOtp,
        data: request.toJson(),
      );
      return OTPResponseModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Verify OTP failed: $e');
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      await apiClient.post(ApiEndpoints.forgotPassword, data: {'email': email});
    } catch (e) {
      throw Exception('Forgot password failed: $e');
    }
  }

  @override
  Future<void> resetPassword(
    String email,
    String newPassword,
    String otp,
  ) async {
    try {
      await apiClient.post(
        ApiEndpoints.resetPassword,
        data: {'email': email, 'new_password': newPassword, 'otp': otp},
      );
    } catch (e) {
      throw Exception('Reset password failed: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await apiClient.post(ApiEndpoints.logout);
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }

  @override
  Future<AuthResponseModel> refreshToken(String refreshToken) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.refreshToken,
        data: {'refresh_token': refreshToken},
      );
      return AuthResponseModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Refresh token failed: $e');
    }
  }

  @override
  Future<String> googleSignIn() async {
    try {
      final response = await apiClient.post(ApiEndpoints.googleAuth);
      return response.data['data']['token'] ?? '';
    } catch (e) {
      throw Exception('Google sign in failed: $e');
    }
  }

  @override
  Future<String> facebookSignIn() async {
    try {
      final response = await apiClient.post(ApiEndpoints.facebookAuth);
      return response.data['data']['token'] ?? '';
    } catch (e) {
      throw Exception('Facebook sign in failed: $e');
    }
  }

  @override
  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      await apiClient.post(
        ApiEndpoints.changePassword,
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
      );
    } catch (e) {
      throw Exception('Change password failed: $e');
    }
  }
}
