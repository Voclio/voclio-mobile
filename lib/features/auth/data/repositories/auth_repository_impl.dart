import '../../domain/entities/auth_request.dart';
import '../../domain/entities/auth_response.dart';
import '../../domain/entities/otp_request.dart';
import '../../domain/entities/otp_response.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/auth_request_model.dart';
import '../models/otp_request_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  @override
  Future<AuthResponse> login(AuthRequest request) async {
    final requestModel = AuthRequestModel.fromEntity(request);
    final responseModel = await _remoteDataSource.login(requestModel);
    await _localDataSource.saveAuthData(responseModel);
    return responseModel;
  }

  @override
  Future<AuthResponse> register(AuthRequest request) async {
    final requestModel = AuthRequestModel.fromEntity(request);
    final responseModel = await _remoteDataSource.register(requestModel);
    await _localDataSource.saveAuthData(responseModel);
    return responseModel;
  }

  @override
  Future<OTPResponse> sendOTP(String email, OTPType type) async {
    final responseModel = await _remoteDataSource.sendOTP(email, type);
    return responseModel;
  }

  @override
  Future<OTPResponse> verifyOTP(OTPRequest request) async {
    final requestModel = OTPRequestModel.fromEntity(request);
    final responseModel = await _remoteDataSource.verifyOTP(requestModel);
    return responseModel;
  }

  @override
  Future<void> forgotPassword(String email) async {
    await _remoteDataSource.forgotPassword(email);
  }

  @override
  Future<void> resetPassword(String email, String newPassword, String otp) async {
    await _remoteDataSource.resetPassword(email, newPassword, otp);
  }

  @override
  Future<void> logout() async {
    await _remoteDataSource.logout();
    await _localDataSource.clearAuthData();
  }

  @override
  Future<AuthResponse> refreshToken(String refreshToken) async {
    final responseModel = await _remoteDataSource.refreshToken(refreshToken);
    await _localDataSource.saveAuthData(responseModel);
    return responseModel;
  }
}
