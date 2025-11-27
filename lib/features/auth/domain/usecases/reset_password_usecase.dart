import '../repositories/auth_repository.dart';

class ResetPasswordUseCase {
  final AuthRepository _repository;

  ResetPasswordUseCase(this._repository);

  Future<void> call(String email, String newPassword, String otp) async {
    return await _repository.resetPassword(email, newPassword, otp);
  }
}
