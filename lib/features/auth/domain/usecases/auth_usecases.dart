import 'package:dartz/dartz.dart';
import 'package:voclio_app/core/errors/failures.dart';
import '../repositories/auth_repository.dart';

class GoogleSignInUseCase {
  final AuthRepository repository;

  GoogleSignInUseCase(this.repository);

  Future<Either<Failure, String>> call() async {
    return await repository.googleSignIn();
  }
}

class FacebookSignInUseCase {
  final AuthRepository repository;

  FacebookSignInUseCase(this.repository);

  Future<Either<Failure, String>> call() async {
    return await repository.facebookSignIn();
  }
}

class ChangePasswordUseCase {
  final AuthRepository repository;

  ChangePasswordUseCase(this.repository);

  Future<Either<Failure, void>> call(
    String currentPassword,
    String newPassword,
  ) async {
    return await repository.changePassword(currentPassword, newPassword);
  }
}

class ResetPasswordUseCase {
  final AuthRepository repository;

  ResetPasswordUseCase(this.repository);

  Future<Either<Failure, void>> call(String email) async {
    return await repository.resetPassword(email);
  }
}
