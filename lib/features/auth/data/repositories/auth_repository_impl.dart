import 'dart:async';
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
import '../models/auth_response_model.dart';
import '../models/otp_request_model.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource;

  @override
  Future<Either<Failure, AuthResponse?>> checkAuthStatus() async {
    try {
      final authData = await _localDataSource.getAuthData();

      // No cached auth data
      if (authData == null) {
        return const Right(null);
      }

      // Validate cached data
      if (authData.token.isEmpty || authData.refreshToken.isEmpty) {
        // Invalid cached data, clear it
        await _localDataSource.clearAuthData();
        return const Right(null);
      }

      // Check if token is expired or expiring soon
      final now = DateTime.now();
      final expiresSoon = authData.expiresAt.isBefore(
        now.add(const Duration(minutes: 1)),
      );

      if (expiresSoon) {
        // Return cached data and let interceptor handle refresh
        // This prevents blocking the UI on app startup
        return Right(authData);
      }

      // Token still valid, return cached data
      return Right(authData);
    } catch (e) {
      // Error reading cache, clear it and return null
      try {
        await _localDataSource.clearAuthData();
      } catch (_) {}
      return const Right(null);
    }
  }

  @override
  Future<Either<Failure, AuthResponse>> login(AuthRequest request) async {
    try {
      final requestModel = AuthRequestModel.fromEntity(request);
      final responseModel = await _remoteDataSource
          .login(requestModel)
          .timeout(
            const Duration(seconds: 25),
            onTimeout: () {
              throw ServerException(
                408,
                'Login request timed out. Please check your internet connection and try again.',
              );
            },
          );
      await _localDataSource.saveAuthData(responseModel);
      return Right(responseModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on TimeoutException {
      return Left(
        ServerFailure(
          'Connection timeout. Please check your internet connection and try again.',
        ),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthResponse>> register(AuthRequest request) async {
    try {
      final requestModel = AuthRequestModel.fromEntity(request);
      final responseModel = await _remoteDataSource
          .register(requestModel)
          .timeout(
            const Duration(seconds: 25),
            onTimeout: () {
              throw ServerException(
                408,
                'Registration timed out. Please try again.',
              );
            },
          );

      // Only save auth data if an OTP was provided (meaning this is the verification step)
      // AND we received a valid token.
      if (request.otp != null &&
          request.otp!.isNotEmpty &&
          responseModel.token.isNotEmpty) {
        await _localDataSource.saveAuthData(responseModel);
      }

      return Right(responseModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on TimeoutException {
      return Left(ServerFailure('Connection timeout. Please try again.'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, OTPResponse>> sendOTP(
    String email,
    OTPType type,
  ) async {
    try {
      final responseModel = await _remoteDataSource
          .sendOTP(email, type)
          .timeout(
            const Duration(seconds: 20),
            onTimeout: () {
              throw ServerException(
                408,
                'OTP request timed out. Please try again.',
              );
            },
          );
      return Right(responseModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on TimeoutException {
      return Left(ServerFailure('Connection timeout. Please try again.'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, OTPResponse>> verifyOTP(OTPRequest request) async {
    try {
      final requestModel = OTPRequestModel.fromEntity(request);
      final responseModel = await _remoteDataSource
          .verifyOTP(requestModel)
          .timeout(
            const Duration(seconds: 20),
            onTimeout: () {
              throw ServerException(
                408,
                'OTP verification timed out. Please try again.',
              );
            },
          );

      // If verification returns a token (registration flow), save it.
      if (responseModel.token != null && responseModel.token!.isNotEmpty) {
        await _localDataSource.saveAuthData(
          AuthResponseModel(
            user: UserModel.fromEntity(responseModel.user!),
            token: responseModel.token!,
            refreshToken: responseModel.refreshToken ?? '',
            expiresAt: responseModel.expiresAt,
          ),
        );
      }

      return Right(responseModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on TimeoutException {
      return Left(ServerFailure('Connection timeout. Please try again.'));
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
  Future<Either<Failure, void>> resetPassword(
    String token,
    String newPassword,
  ) async {
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
      // Clear local data immediately
      await _localDataSource.clearAuthData();

      // Try to notify server in background but don't wait
      _remoteDataSource.logout().catchError((_) {});

      return const Right(null);
    } catch (e) {
      // Ensure local data is cleared even on error
      await _localDataSource.clearAuthData();
      return const Right(null); // Always succeed logout locally
    }
  }

  @override
  Future<Either<Failure, AuthResponse>> refreshToken(
    String refreshToken,
  ) async {
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
      final response = await _remoteDataSource.googleSignIn().timeout(
        const Duration(seconds: 12),
        onTimeout: () {
          throw ServerException(408, 'Google sign in timed out.');
        },
      );
      await _localDataSource.saveAuthData(response);
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on TimeoutException {
      return Left(ServerFailure('Connection timeout. Please try again.'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthResponse>> facebookSignIn() async {
    try {
      final response = await _remoteDataSource.facebookSignIn().timeout(
        const Duration(seconds: 12),
        onTimeout: () {
          throw ServerException(408, 'Facebook sign in timed out.');
        },
      );
      await _localDataSource.saveAuthData(response);
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on TimeoutException {
      return Left(ServerFailure('Connection timeout. Please try again.'));
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
      await _remoteDataSource
          .changePassword(currentPassword, newPassword)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw ServerException(408, 'Change password timed out.');
            },
          );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on TimeoutException {
      return Left(ServerFailure('Connection timeout. Please try again.'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, OTPResponse>> resendOTP(
    String email,
    OTPType type,
  ) async {
    try {
      final responseModel = await _remoteDataSource
          .resendOTP(email, type)
          .timeout(
            const Duration(seconds: 8),
            onTimeout: () {
              throw ServerException(408, 'Resend OTP timed out.');
            },
          );
      return Right(responseModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on TimeoutException {
      return Left(ServerFailure('Connection timeout. Please try again.'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthResponse>> getProfile() async {
    try {
      final responseModel = await _remoteDataSource.getProfile().timeout(
        const Duration(seconds: 8),
        onTimeout: () {
          throw ServerException(
            408,
            'Profile request timed out. Please try again.',
          );
        },
      );
      await _localDataSource.saveAuthData(responseModel);
      return Right(responseModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on TimeoutException {
      return Left(
        ServerFailure(
          'Connection timeout. Please check your internet connection.',
        ),
      );
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
      final response = await _remoteDataSource
          .updateProfile(name, phoneNumber)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw ServerException(408, 'Update profile timed out.');
            },
          );
      await _localDataSource.saveAuthData(response);
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on TimeoutException {
      return Left(ServerFailure('Connection timeout. Please try again.'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
