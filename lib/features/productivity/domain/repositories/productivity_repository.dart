import 'package:dartz/dartz.dart';
import 'package:voclio_app/core/errors/failures.dart';
import '../entities/productivity_entities.dart';

abstract class ProductivityRepository {
  Future<Either<Failure, FocusSessionEntity>> startFocusSession(
    int duration,
    String? sound,
    int? volume,
  );
  Future<Either<Failure, List<FocusSessionEntity>>> getFocusSessions();
  Future<Either<Failure, void>> endFocusSession(String id, int actualDuration);
  Future<Either<Failure, StreakEntity>> getStreak();
  Future<Either<Failure, List<AchievementEntity>>> getAchievements();
}
