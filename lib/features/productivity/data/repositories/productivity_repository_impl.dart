import 'package:dartz/dartz.dart';
import 'package:voclio_app/core/errors/failures.dart';
import 'package:voclio_app/features/productivity/domain/entities/productivity_entities.dart';
import '../../domain/repositories/productivity_repository.dart';
import '../datasources/productivity_remote_datasource.dart';

class ProductivityRepositoryImpl implements ProductivityRepository {
  final ProductivityRemoteDataSource remoteDataSource;

  ProductivityRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, FocusSessionEntity>> startFocusSession(
    int duration,
    String? sound,
    int? volume,
  ) async {
    try {
      final session = await remoteDataSource.startFocusSession(
        duration,
        sound,
        volume,
      );
      return Right(session.toEntity());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<FocusSessionEntity>>> getFocusSessions() async {
    try {
      final sessions = await remoteDataSource.getFocusSessions();
      return Right(sessions.map((s) => s.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> endFocusSession(
    String id,
    int actualDuration,
  ) async {
    try {
      await remoteDataSource.endFocusSession(id, actualDuration);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, StreakEntity>> getStreak() async {
    try {
      final streak = await remoteDataSource.getStreak();
      return Right(streak.toEntity());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<AchievementEntity>>> getAchievements() async {
    try {
      final achievements = await remoteDataSource.getAchievements();
      return Right(achievements.map((a) => a.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
