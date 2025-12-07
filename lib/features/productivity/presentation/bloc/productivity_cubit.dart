import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/productivity_usecases.dart';
import 'productivity_state.dart';

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

  Future<void> endFocusSession(String id, int actualDuration) async {
    final result = await endFocusSessionUseCase(id, actualDuration);

    result.fold(
      (failure) => emit(ProductivityError('Failed to end focus session')),
      (_) => emit(ProductivityInitial()),
    );
  }
}
