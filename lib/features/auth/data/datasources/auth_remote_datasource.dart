import '../models/auth_request_model.dart';
import '../models/auth_response_model.dart';
import '../models/otp_request_model.dart';
import '../models/otp_response_model.dart';
import '../../domain/entities/otp_request.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login(AuthRequestModel request);
  Future<AuthResponseModel> register(AuthRequestModel request);
  Future<OTPResponseModel> sendOTP(String email, OTPType type);
  Future<OTPResponseModel> resendOTP(String email, OTPType type);
  Future<OTPResponseModel> verifyOTP(OTPRequestModel request);
  Future<void> forgotPassword(String email);
  Future<void> resetPassword(String token, String newPassword);
  Future<void> logout();
  Future<AuthResponseModel> refreshToken(String refreshToken);
  Future<AuthResponseModel> googleSignIn();
  Future<AuthResponseModel> facebookSignIn();
  Future<void> changePassword(String currentPassword, String newPassword);
  Future<AuthResponseModel> getProfile();
  Future<AuthResponseModel> updateProfile(String name, String phoneNumber);
}
