import 'package:dartz/dartz.dart';
import 'package:voclio_app/core/errors/failures.dart';
import '../repositories/auth_repository.dart';

class ResetPasswordUseCase {
  final AuthRepository _repository;

  ResetPasswordUseCase(this._repository);

  Future<Either<Failure, void>> call(String token, String newPassword) async {
    return await _repository.resetPassword(token, newPassword);
  }
}
