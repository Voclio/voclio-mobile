import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/auth_response.dart';
import '../repositories/auth_repository.dart';

class CheckAuthStatusUseCase {
  final AuthRepository repository;

  CheckAuthStatusUseCase(this.repository);

  Future<Either<Failure, AuthResponse?>> call() async {
    return await repository.checkAuthStatus();
  }
}
