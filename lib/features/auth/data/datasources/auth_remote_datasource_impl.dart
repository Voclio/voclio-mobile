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
          'fullName': 'Test User',
          'avatar': null,
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': null,
        },
        'token': 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
        'refreshToken': 'mock_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
        'expiresAt': DateTime.now().add(const Duration(hours: 24)).toIso8601String(),
      });
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  @override
  Future<AuthResponseModel> register(AuthRequestModel request) async {
    try {
      // TODO: Replace with your actual API endpoint
      await _dio.post(
        'https://your-api.com/auth/register',
        data: request.toJson(),
      );
      
      // For now, return a mock response
      return AuthResponseModel.fromJson({
        'user': {
          'id': '1',
          'email': request.email,
          'fullName': request.fullName ?? 'New User',
          'avatar': null,
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': null,
        },
        'token': 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
        'refreshToken': 'mock_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
        'expiresAt': DateTime.now().add(const Duration(hours: 24)).toIso8601String(),
      });
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  @override
  Future<OTPResponseModel> sendOTP(String email, OTPType type) async {
    try {
      // TODO: Replace with your actual API endpoint
      await _dio.post(
        'https://your-api.com/auth/send-otp',
        data: {
          'email': email,
          'type': type.toString().split('.').last,
        },
      );
      
      // For now, return a mock response
      return OTPResponseModel.fromJson({
        'success': true,
        'message': 'OTP sent successfully',
        'sessionId': 'mock_session_${DateTime.now().millisecondsSinceEpoch}',
        'expiresAt': DateTime.now().add(const Duration(minutes: 5)).toIso8601String(),
      });
    } catch (e) {
      throw Exception('Send OTP failed: $e');
    }
  }

  @override
  Future<OTPResponseModel> verifyOTP(OTPRequestModel request) async {
    try {
      // TODO: Replace with your actual API endpoint
      await _dio.post(
        'https://your-api.com/auth/verify-otp',
        data: request.toJson(),
      );
      
      // For now, return a mock response
      return OTPResponseModel.fromJson({
        'success': true,
        'message': 'OTP verified successfully',
        'sessionId': 'mock_session_${DateTime.now().millisecondsSinceEpoch}',
        'expiresAt': DateTime.now().add(const Duration(minutes: 5)).toIso8601String(),
      });
    } catch (e) {
      throw Exception('Verify OTP failed: $e');
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      // TODO: Replace with your actual API endpoint
      await _dio.post(
        'https://your-api.com/auth/forgot-password',
        data: {'email': email},
      );
    } catch (e) {
      throw Exception('Forgot password failed: $e');
    }
  }

  @override
  Future<void> resetPassword(String email, String newPassword, String otp) async {
    try {
      // TODO: Replace with your actual API endpoint
      await _dio.post(
        'https://your-api.com/auth/reset-password',
        data: {
          'email': email,
          'newPassword': newPassword,
          'otp': otp,
        },
      );
    } catch (e) {
      throw Exception('Reset password failed: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      // TODO: Replace with your actual API endpoint
      await _dio.post('https://your-api.com/auth/logout');
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }

  @override
  Future<AuthResponseModel> refreshToken(String refreshToken) async {
    try {
      // TODO: Replace with your actual API endpoint
      await _dio.post(
        'https://your-api.com/auth/refresh',
        data: {'refreshToken': refreshToken},
      );
      
      // For now, return a mock response
      return AuthResponseModel.fromJson({
        'user': {
          'id': '1',
          'email': 'user@example.com',
          'fullName': 'Test User',
          'avatar': null,
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': null,
        },
        'token': 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
        'refreshToken': 'mock_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
        'expiresAt': DateTime.now().add(const Duration(hours: 24)).toIso8601String(),
      });
    } catch (e) {
      throw Exception('Refresh token failed: $e');
    }
  }
}
