import '../entities/otp_request.dart';
import '../entities/otp_response.dart';
import '../repositories/auth_repository.dart';

class VerifyOTPUseCase {
  final AuthRepository _repository;

  VerifyOTPUseCase(this._repository);

  Future<OTPResponse> call(OTPRequest request) async {
    return await _repository.verifyOTP(request);
  }
}
