import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:voclio_app/features/productivity/domain/entities/productivity_entities.dart';
import 'package:voclio_app/features/productivity/domain/usecases/productivity_usecases.dart';
import 'package:voclio_app/features/productivity/presentation/bloc/productivity_state.dart';

class ProductivityCubit extends Cubit<ProductivityState> {
  final StartFocusSessionUseCase startFocusSessionUseCase;
  final GetStreakUseCase getStreakUseCase;
  final GetAchievementsUseCase getAchievementsUseCase;
  final EndFocusSessionUseCase endFocusSessionUseCase;

  ProductivityCubit({
    required this.startFocusSessionUseCase,
    required this.getStreakUseCase,
    required this.getAchievementsUseCase,
    required this.endFocusSessionUseCase,
  }) : super(ProductivityInitial());

  Future<void> startFocusSession(
    int duration,
    String? sound,
    int? volume,
  ) async {
    emit(ProductivityLoading());

    final result = await startFocusSessionUseCase(duration, sound, volume);

    result.fold(
      (failure) => emit(ProductivityError('Failed to start focus session')),
      (session) => emit(FocusSessionStarted(session)),
    );
  }

  Future<void> loadStreak() async {
    emit(ProductivityLoading());

    final result = await getStreakUseCase();

    result.fold(
      (failure) => emit(ProductivityError('Failed to load streak')),
      (streak) => emit(StreakLoaded(streak)),
    );
  }

  Future<void> loadAchievements() async {
    emit(ProductivityLoading());

    final result = await getAchievementsUseCase();

    result.fold(
      (failure) => emit(ProductivityError('Failed to load achievements')),
      (achievements) => emit(AchievementsLoaded(achievements)),
    );
  }

  Future<void> loadProductivityData() async {
    emit(ProductivityLoading());

    final results = await Future.wait([
      getStreakUseCase(),
      getAchievementsUseCase(),
    ]);

    final streakResult = results[0] as Either<dynamic, StreakEntity>;
    final achievementsResult =
        results[1] as Either<dynamic, List<AchievementEntity>>;

    streakResult.fold(
      (failure) => emit(ProductivityError('Failed to load streak data')),
      (streak) => achievementsResult.fold(
        (failure) => emit(ProductivityError('Failed to load achievements')),
        (achievements) => emit(
          ProductivityDataLoaded(streak: streak, achievements: achievements),
        ),
      ),
    );
  }

  Future<void> endFocusSession(String id, int actualDuration) async {
    final result = await endFocusSessionUseCase(id, actualDuration);

    result.fold(
      (failure) => emit(ProductivityError('Failed to end focus session')),
      (_) => emit(ProductivityInitial()),
    );
  }
}
