import '../models/auth_request_model.dart';
import '../models/auth_response_model.dart';
import '../models/otp_request_model.dart';
import '../models/otp_response_model.dart';
import '../../domain/entities/otp_request.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login(AuthRequestModel request);
  Future<AuthResponseModel> register(AuthRequestModel request);
  Future<OTPResponseModel> sendOTP(String email, OTPType type);
  Future<OTPResponseModel> verifyOTP(OTPRequestModel request);
  Future<void> forgotPassword(String email);
  Future<void> resetPassword(String email, String newPassword, String otp);
  Future<void> logout();
  Future<AuthResponseModel> refreshToken(String refreshToken);
}
