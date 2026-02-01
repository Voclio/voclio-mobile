import 'package:dartz/dartz.dart';
import 'package:voclio_app/core/errors/failures.dart';
import '../repositories/auth_repository.dart';

class ChangePasswordUseCase {
  final AuthRepository _repository;

  ChangePasswordUseCase(this._repository);

  Future<Either<Failure, void>> call(
    String currentPassword,
    String newPassword,
  ) async {
    return await _repository.changePassword(currentPassword, newPassword);
  }
}
