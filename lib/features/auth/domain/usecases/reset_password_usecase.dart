import '../repositories/auth_repository.dart';

class ResetPasswordUseCase {
  final AuthRepository _repository;

  ResetPasswordUseCase(this._repository);

  Future<void> call(String token, String newPassword) async {
    return await _repository.resetPassword(token, newPassword);
  }
}
