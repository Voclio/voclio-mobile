import 'package:dartz/dartz.dart';
import 'package:voclio_app/core/api/api_client.dart';
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
  Future<Either<Failure, AuthResponse>> login(AuthRequest request) async {
    try {
      final requestModel = AuthRequestModel.fromEntity(request);
      final responseModel = await _remoteDataSource.login(requestModel);
      await _localDataSource.saveAuthData(responseModel);
      return Right(responseModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthResponse>> register(AuthRequest request) async {
    try {
      final requestModel = AuthRequestModel.fromEntity(request);
      final responseModel = await _remoteDataSource.register(requestModel);
      await _localDataSource.saveAuthData(responseModel);
      return Right(responseModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, OTPResponse>> sendOTP(String email, OTPType type) async {
    try {
      final responseModel = await _remoteDataSource.sendOTP(email, type);
      return Right(responseModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, OTPResponse>> verifyOTP(OTPRequest request) async {
    try {
      final requestModel = OTPRequestModel.fromEntity(request);
      final responseModel = await _remoteDataSource.verifyOTP(requestModel);
      return Right(responseModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> forgotPassword(String email) async {
    try {
      await _remoteDataSource.forgotPassword(email);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword(String token, String newPassword) async {
    try {
      await _remoteDataSource.resetPassword(token, newPassword);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _remoteDataSource.logout();
      await _localDataSource.clearAuthData();
      return const Right(null);
    } on ServerException catch (e) {
      // Even if server logout fails, we should clear local data
      await _localDataSource.clearAuthData();
      return Left(ServerFailure(e.message));
    } catch (e) {
       await _localDataSource.clearAuthData();
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthResponse>> refreshToken(String refreshToken) async {
    try {
      final responseModel = await _remoteDataSource.refreshToken(refreshToken);
      await _localDataSource.saveAuthData(responseModel);
      return Right(responseModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthResponse>> googleSignIn() async {
    try {
      final response = await _remoteDataSource.googleSignIn();
      await _localDataSource.saveAuthData(response);
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthResponse>> facebookSignIn() async {
    try {
      final response = await _remoteDataSource.facebookSignIn();
      await _localDataSource.saveAuthData(response);
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
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
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
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
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
