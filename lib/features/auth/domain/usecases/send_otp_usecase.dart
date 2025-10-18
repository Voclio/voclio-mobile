import '../entities/otp_request.dart';
import '../entities/otp_response.dart';
import '../repositories/auth_repository.dart';

class SendOTPUseCase {
  final AuthRepository _repository;

  SendOTPUseCase(this._repository);

  Future<OTPResponse> call(String email, OTPType type) async {
    return await _repository.sendOTP(email, type);
  }
}
