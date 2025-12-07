import 'package:equatable/equatable.dart';
import '../../domain/entities/productivity_entities.dart';

abstract class ProductivityState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProductivityInitial extends ProductivityState {}

class ProductivityLoading extends ProductivityState {}

class FocusSessionStarted extends ProductivityState {
  final FocusSessionEntity session;

  FocusSessionStarted(this.session);

  @override
  List<Object?> get props => [session];
}

class StreakLoaded extends ProductivityState {
  final StreakEntity streak;

  StreakLoaded(this.streak);

  @override
  List<Object?> get props => [streak];
}

class AchievementsLoaded extends ProductivityState {
  final List<AchievementEntity> achievements;

  AchievementsLoaded(this.achievements);

  @override
  List<Object?> get props => [achievements];
}

class ProductivityError extends ProductivityState {
  final String message;

  ProductivityError(this.message);

  @override
  List<Object?> get props => [message];
}
