import 'package:dartz/dartz.dart';
import 'package:voclio_app/core/errors/failures.dart';
import '../entities/auth_request.dart';
import '../entities/auth_response.dart';
import '../entities/otp_request.dart';
import '../entities/otp_response.dart';

abstract class AuthRepository {
  Future<AuthResponse> login(AuthRequest request);
  Future<AuthResponse> register(AuthRequest request);
  Future<OTPResponse> sendOTP(String email, OTPType type);
  Future<OTPResponse> verifyOTP(OTPRequest request);
  Future<void> forgotPassword(String email);
  Future<void> resetPassword(String email, String newPassword, String otp);
  Future<void> logout();
  Future<AuthResponse> refreshToken(String refreshToken);
  Future<Either<Failure, String>> googleSignIn();
  Future<Either<Failure, String>> facebookSignIn();
  Future<Either<Failure, void>> changePassword(
    String currentPassword,
    String newPassword,
  );
}
