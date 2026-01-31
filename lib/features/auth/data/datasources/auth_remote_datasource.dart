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
    final response = await apiClient.post(
      ApiEndpoints.login,
      data: request.toJson(),
    );
    return AuthResponseModel.fromJson(response.data);
  }

  @override
  Future<AuthResponseModel> register(AuthRequestModel request) async {
    final response = await apiClient.post(
      ApiEndpoints.register,
      data: request.toJson(),
    );
    return AuthResponseModel.fromJson(response.data);
  }

  @override
  Future<OTPResponseModel> sendOTP(String email, OTPType type) async {
    final response = await apiClient.post(
      ApiEndpoints.sendOtp,
      data: {'email': email, 'type': type.toString().split('.').last},
    );
    return OTPResponseModel.fromJson(response.data);
  }

  @override
  Future<OTPResponseModel> verifyOTP(OTPRequestModel request) async {
    final response = await apiClient.post(
      ApiEndpoints.verifyOtp,
      data: request.toJson(),
    );
    return OTPResponseModel.fromJson(response.data);
  }

  @override
  Future<void> forgotPassword(String email) async {
    await apiClient.post(ApiEndpoints.forgotPassword, data: {'email': email});
  }

  @override
  Future<void> resetPassword(String token, String newPassword) async {
    await apiClient.post(
      ApiEndpoints.resetPassword,
      data: {'token': token, 'new_password': newPassword},
    );
  }

  @override
  Future<void> logout() async {
    await apiClient.post(ApiEndpoints.logout);
  }

  @override
  Future<AuthResponseModel> refreshToken(String refreshToken) async {
    final response = await apiClient.post(
      ApiEndpoints.refreshToken,
      data: {'refresh_token': refreshToken},
    );
    return AuthResponseModel.fromJson(response.data);
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
    await apiClient.post(
      ApiEndpoints.changePassword,
      data: {
        'current_password': currentPassword,
        'new_password': newPassword,
      },
    );
  }

  @override
  Future<AuthResponseModel> updateProfile(String name, String phoneNumber) async {
     final response = await apiClient.post(
       ApiEndpoints.updateProfile,
       data: {'name': name, 'phone_number': phoneNumber},
     );
     return AuthResponseModel.fromJson(response.data);
  }
}
