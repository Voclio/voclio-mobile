import 'package:dartz/dartz.dart';
import 'package:voclio_app/core/errors/failures.dart';
import '../entities/otp_request.dart';
import '../entities/otp_response.dart';
import '../repositories/auth_repository.dart';

class VerifyOTPUseCase {
  final AuthRepository _repository;

  VerifyOTPUseCase(this._repository);

  Future<Either<Failure, OTPResponse>> call(OTPRequest request) async {
    return await _repository.verifyOTP(request);
  }
}
