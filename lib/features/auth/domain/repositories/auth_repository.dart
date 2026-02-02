import 'package:dartz/dartz.dart';
import 'package:voclio_app/core/errors/failures.dart';
import '../entities/auth_request.dart';
import '../entities/auth_response.dart';
import '../entities/otp_request.dart';
import '../entities/otp_response.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthResponse>> login(AuthRequest request);
  Future<Either<Failure, AuthResponse>> register(AuthRequest request);
  Future<Either<Failure, OTPResponse>> sendOTP(String email, OTPType type);
  Future<Either<Failure, OTPResponse>> verifyOTP(OTPRequest request);
  Future<Either<Failure, void>> forgotPassword(String email);
  Future<Either<Failure, void>> resetPassword(String token, String newPassword);
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, AuthResponse>> refreshToken(String refreshToken);
  Future<Either<Failure, AuthResponse>> googleSignIn();
  Future<Either<Failure, AuthResponse>> facebookSignIn();
  Future<Either<Failure, void>> changePassword(
    String currentPassword,
    String newPassword,
  );
  Future<Either<Failure, AuthResponse>> updateProfile(String name, String phoneNumber);
}
