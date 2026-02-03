import 'package:dartz/dartz.dart';
import 'package:voclio_app/core/errors/failures.dart';
import '../entities/otp_request.dart';
import '../entities/otp_response.dart';
import '../repositories/auth_repository.dart';

class ResendOTPUseCase {
  final AuthRepository _repository;

  ResendOTPUseCase(this._repository);

  Future<Either<Failure, OTPResponse>> call(String email, OTPType type) async {
    return await _repository.resendOTP(email, type);
  }
}
