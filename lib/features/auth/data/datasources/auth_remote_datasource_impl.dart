import 'package:dio/dio.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/auth_request_model.dart';
import '../models/auth_response_model.dart';
import '../models/otp_request_model.dart';
import '../models/otp_response_model.dart';
import '../../domain/entities/otp_request.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSourceImpl() : _dio = Dio();

  @override
  Future<AuthResponseModel> login(AuthRequestModel request) async {
    try {
      // TODO: Replace with your actual API endpoint
      await _dio.post(
        'https://your-api.com/auth/login',
        data: request.toJson(),
      );

      // For now, return a mock response
      // Replace this with actual API response parsing
      return AuthResponseModel.fromJson({
        'user': {
          'id': '1',
          'email': request.email,
          'name': 'Test User',
          'createdAt': DateTime.now().toIso8601String(),
        },
        'token': 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
        'refresh_token':
            'mock_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
      });
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  @override
  Future<AuthResponseModel> register(AuthRequestModel request) async {
    try {
      await _dio.post(
        'https://your-api.com/auth/register',
        data: request.toJson(),
      );

      return AuthResponseModel.fromJson({
        'user': {
          'id': '1',
          'email': request.email,
          'name': request.fullName ?? 'New User',
          'createdAt': DateTime.now().toIso8601String(),
        },
        'token': 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
        'refresh_token':
            'mock_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
      });
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  @override
  Future<OTPResponseModel> sendOTP(String email, OTPType type) async {
    try {
      await _dio.post(
        'https://your-api.com/auth/send-otp',
        data: {'email': email, 'type': type.toString().split('.').last},
      );

      return OTPResponseModel.fromJson({
        'success': true,
        'message': 'OTP sent successfully',
      });
    } catch (e) {
      throw Exception('Send OTP failed: $e');
    }
  }

  @override
  Future<OTPResponseModel> verifyOTP(OTPRequestModel request) async {
    try {
      await _dio.post(
        'https://your-api.com/auth/verify-otp',
        data: request.toJson(),
      );

      return OTPResponseModel.fromJson({
        'success': true,
        'message': 'OTP verified successfully',
      });
    } catch (e) {
      throw Exception('Verify OTP failed: $e');
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      await _dio.post(
        'https://your-api.com/auth/forgot-password',
        data: {'email': email},
      );
    } catch (e) {
      throw Exception('Forgot password failed: $e');
    }
  }

  @override
  Future<void> resetPassword(String token, String newPassword) async {
    try {
      await _dio.post(
        'https://your-api.com/auth/reset-password',
        data: {'token': token, 'new_password': newPassword},
      );
    } catch (e) {
      throw Exception('Reset password failed: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _dio.post('https://your-api.com/auth/logout');
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }

  @override
  Future<AuthResponseModel> refreshToken(String refreshToken) async {
    try {
      await _dio.post(
        'https://your-api.com/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      return AuthResponseModel.fromJson({
        'user': {
          'id': '1',
          'email': 'user@example.com',
          'name': 'Test User',
          'createdAt': DateTime.now().toIso8601String(),
        },
        'token': 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
        'refresh_token':
            'mock_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
      });
    } catch (e) {
      throw Exception('Refresh token failed: $e');
    }
  }

  @override
  Future<AuthResponseModel> googleSignIn() async {
    try {
      final idToken = 'YOUR_GOOGLE_ID_TOKEN';
      await _dio.post(
          'https://your-api.com/auth/google',
          data: {'id_token': idToken}
      );
      return AuthResponseModel.fromJson({
         'user': {
          'id': '1',
          'email': 'user@example.com',
          'name': 'Google User',
        },
        'token': 'mock_google_token_${DateTime.now().millisecondsSinceEpoch}',
        'refresh_token': 'mock_refresh_token',
        'expires_at': DateTime.now().add(const Duration(hours: 24)).toIso8601String(),
      });
    } catch (e) {
      throw Exception('Google sign in failed: $e');
    }
  }

  @override
  Future<AuthResponseModel> facebookSignIn() async {
    try {
      final accessToken = 'YOUR_FACEBOOK_ACCESS_TOKEN';
       await _dio.post(
          'https://your-api.com/auth/facebook',
          data: {'access_token': accessToken}
      );
      return AuthResponseModel.fromJson({
         'user': {
          'id': '1',
          'email': 'user@example.com',
          'name': 'Facebook User',
        },
        'token': 'mock_facebook_token_${DateTime.now().millisecondsSinceEpoch}',
         'refresh_token': 'mock_refresh_token',
         'expires_at': DateTime.now().add(const Duration(hours: 24)).toIso8601String(),
      });
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
      await _dio.post(
        'https://your-api.com/auth/change-password',
        data: {'current_password': currentPassword, 'new_password': newPassword},
      );
    } catch (e) {
      throw Exception('Change password failed: $e');
    }
  }

  @override
  Future<AuthResponseModel> updateProfile(String name, String phoneNumber) async {
     try {
      await _dio.post(
        'https://your-api.com/auth/profile',
        data: {'name': name, 'phone_number': phoneNumber},
      );
      return AuthResponseModel.fromJson({
         'user': {
          'id': '1',
          'email': 'user@example.com',
          'name': name,
          'phone_number': phoneNumber
        },
        'token': 'mock_token',
         'refresh_token': 'mock_refresh_token',
         'expires_at': DateTime.now().add(const Duration(hours: 24)).toIso8601String(),
      });
    } catch (e) {
      throw Exception('Update profile failed: $e');
    }
  }
}
