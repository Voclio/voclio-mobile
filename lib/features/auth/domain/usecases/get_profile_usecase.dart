import 'package:dartz/dartz.dart';
import 'package:voclio_app/core/errors/failures.dart';
import '../entities/auth_response.dart';
import '../repositories/auth_repository.dart';

class GetProfileUseCase {
  final AuthRepository _repository;

  GetProfileUseCase(this._repository);

  Future<Either<Failure, AuthResponse>> call() async {
    return await _repository.getProfile();
  }
}
