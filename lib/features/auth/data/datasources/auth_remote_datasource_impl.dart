import 'package:voclio_app/core/api/api_client.dart';
import 'package:voclio_app/core/api/api_endpoints.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/auth_request_model.dart';
import '../models/auth_response_model.dart';
import '../models/otp_request_model.dart';
import '../models/otp_response_model.dart';
import '../../domain/entities/otp_request.dart';

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
      data: {'email': email, 'type': type.toShortString},
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
      // Initialize Google Sign-In
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception('Google sign in was cancelled');
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Exception('Failed to get Google ID token');
      }

      // Send ID token to backend
      final response = await apiClient.post(
        ApiEndpoints.googleAuth,
        data: {'id_token': idToken},
      );
      return AuthResponseModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Google sign in failed: $e');
    }
  }

  @override
  Future<AuthResponseModel> facebookSignIn() async {
    try {
      // Trigger the Facebook sign-in flow
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      if (result.status != LoginStatus.success) {
        throw Exception(
          'Facebook sign in was cancelled or failed: ${result.status}',
        );
      }

      final AccessToken? accessToken = result.accessToken;

      if (accessToken == null) {
        throw Exception('Failed to get Facebook access token');
      }

      // Send access token to backend
      final response = await apiClient.post(
        ApiEndpoints.facebookAuth,
        data: {'access_token': accessToken.tokenString},
      );
      return AuthResponseModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Facebook sign in failed: $e');
    }
  }

  @override
  Future<OTPResponseModel> resendOTP(String email, OTPType type) async {
    final response = await apiClient.post(
      ApiEndpoints.resendOtp,
      data: {'email': email, 'type': type.toShortString},
    );
    return OTPResponseModel.fromJson(response.data);
  }

  @override
  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    await apiClient.put(
      ApiEndpoints.changePassword,
      data: {'current_password': currentPassword, 'new_password': newPassword},
    );
  }

  @override
  Future<AuthResponseModel> getProfile() async {
    final response = await apiClient.get(ApiEndpoints.profile);
    return AuthResponseModel.fromJson(response.data);
  }

  @override
  Future<AuthResponseModel> updateProfile(
    String name,
    String phoneNumber,
  ) async {
    final response = await apiClient.put(
      ApiEndpoints.updateProfile,
      data: {'name': name, 'phone_number': phoneNumber},
    );
    return AuthResponseModel.fromJson(response.data);
  }
}
