import 'package:dartz/dartz.dart';
import 'package:voclio_app/core/errors/failures.dart';
import 'package:voclio_app/features/productivity/domain/entities/productivity_entities.dart';
import 'package:voclio_app/features/productivity/domain/entities/ai_suggestion_entity.dart';

abstract class ProductivityRepository {
  Future<Either<Failure, FocusSessionEntity>> startFocusSession(
    int duration,
    String? sound,
    int? volume,
  );
  Future<Either<Failure, List<FocusSessionEntity>>> getFocusSessions();
  Future<Either<Failure, void>> endFocusSession(String id, int actualDuration);
  Future<Either<Failure, void>> deleteFocusSession(String id);
  Future<Either<Failure, StreakEntity>> getStreak();
  Future<Either<Failure, List<AchievementEntity>>> getAchievements();
  Future<Either<Failure, Map<String, dynamic>>> getProductivitySummary();
  Future<Either<Failure, AiSuggestionEntity>> getAiSuggestions();
}
