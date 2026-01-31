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
  Future<void> resetPassword(String token, String newPassword);
  Future<void> logout();
  Future<AuthResponseModel> refreshToken(String refreshToken);
  Future<AuthResponseModel> googleSignIn();
  Future<AuthResponseModel> facebookSignIn();
  Future<void> changePassword(String currentPassword, String newPassword);
  Future<AuthResponseModel> updateProfile(String name, String phoneNumber);
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
  Future<void> resetPassword(String token, String newPassword) async {
    try {
      await apiClient.post(
        ApiEndpoints.resetPassword,
        data: {'token': token, 'new_password': newPassword},
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
  Future<AuthResponseModel> googleSignIn() async {
    try {
      // Assuming token is obtained here or passed logically. 
      // Requirement asks for body {"id_token": ...}
      final String idToken = "YOUR_GOOGLE_ID_TOKEN"; 
      final response = await apiClient.post(
        ApiEndpoints.googleAuth, 
        data: {'id_token': idToken}
      );
      return AuthResponseModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Google sign in failed: $e');
    }
  }

  @override
  Future<AuthResponseModel> facebookSignIn() async {
    try {
      final String accessToken = "YOUR_FACEBOOK_ACCESS_TOKEN";
      final response = await apiClient.post(
          ApiEndpoints.facebookAuth,
          data: {'access_token': accessToken}
      );
      return AuthResponseModel.fromJson(response.data);
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

  @override
  Future<AuthResponseModel> updateProfile(String name, String phoneNumber) async {
    try {
       final response = await apiClient.post(
         ApiEndpoints.updateProfile,
         data: {'name': name, 'phone_number': phoneNumber},
       );
       return AuthResponseModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Update profile failed: $e');
    }
  }
}
