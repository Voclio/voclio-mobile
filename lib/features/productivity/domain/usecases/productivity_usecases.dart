import 'package:dartz/dartz.dart';
import 'package:voclio_app/core/errors/failures.dart';
import '../entities/productivity_entities.dart';
import '../repositories/productivity_repository.dart';

class StartFocusSessionUseCase {
  final ProductivityRepository repository;

  StartFocusSessionUseCase(this.repository);

  Future<Either<Failure, FocusSessionEntity>> call(
    int duration,
    String? sound,
    int? volume,
  ) async {
    return await repository.startFocusSession(duration, sound, volume);
  }
}

class GetStreakUseCase {
  final ProductivityRepository repository;

  GetStreakUseCase(this.repository);

  Future<Either<Failure, StreakEntity>> call() async {
    return await repository.getStreak();
  }
}

class GetAchievementsUseCase {
  final ProductivityRepository repository;

  GetAchievementsUseCase(this.repository);

  Future<Either<Failure, List<AchievementEntity>>> call() async {
    return await repository.getAchievements();
  }
}

class EndFocusSessionUseCase {
  final ProductivityRepository repository;

  EndFocusSessionUseCase(this.repository);

  Future<Either<Failure, void>> call(String id, int actualDuration) async {
    return await repository.endFocusSession(id, actualDuration);
  }
}
