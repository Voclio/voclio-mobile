import '../entities/auth_request.dart';
import '../entities/auth_response.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  Future<AuthResponse> call(AuthRequest request) async {
    return await _repository.login(request);
  }
}
