import 'package:dartz/dartz.dart';
import 'package:voclio_app/core/errors/failures.dart';
import '../entities/auth_request.dart';
import '../entities/auth_response.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository _repository;

  RegisterUseCase(this._repository);

  Future<Either<Failure, AuthResponse>> call(AuthRequest request) async {
    return await _repository.register(request);
  }
}
