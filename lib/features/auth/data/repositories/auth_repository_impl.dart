import 'package:dartz/dartz.dart';
import 'package:voclio_app/core/errors/failures.dart';
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
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource;

  @override
  Future<AuthResponse> login(AuthRequest request) async {
    try {
      final requestModel = AuthRequestModel.fromEntity(request);
      final responseModel = await _remoteDataSource.login(requestModel);
      await _localDataSource.saveAuthData(responseModel);
      return responseModel;
    } catch (e) {
      // Re-throw to preserve the original error details
      rethrow;
    }
  }

  @override
  Future<AuthResponse> register(AuthRequest request) async {
    try {
      final requestModel = AuthRequestModel.fromEntity(request);
      final responseModel = await _remoteDataSource.register(requestModel);
      await _localDataSource.saveAuthData(responseModel);
      return responseModel;
    } catch (e) {
      // Re-throw to preserve the original error details
      rethrow;
    }
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
    try {
      await _remoteDataSource.forgotPassword(email);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> resetPassword(String token, String newPassword) async {
    try {
      await _remoteDataSource.resetPassword(token, newPassword);
    } catch (e) {
      rethrow;
    }
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

  @override
  Future<Either<Failure, String>> googleSignIn() async {
    try {
      final response = await _remoteDataSource.googleSignIn();
      await _localDataSource.saveAuthData(response);
      return Right(response.token);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, String>> facebookSignIn() async {
    try {
      final response = await _remoteDataSource.facebookSignIn();
      await _localDataSource.saveAuthData(response);
      return Right(response.token);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      await _remoteDataSource.changePassword(currentPassword, newPassword);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, AuthResponse>> updateProfile(
    String name,
    String phoneNumber,
  ) async {
    try {
      final response = await _remoteDataSource.updateProfile(name, phoneNumber);
      await _localDataSource.saveAuthData(response);
      return Right(response);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
