import 'package:equatable/equatable.dart';

class FocusSessionEntity extends Equatable {
  final String id;
  final int timerDuration;
  final String? ambientSound;
  final int? soundVolume;
  final bool completed;
  final int? actualDuration;
  final DateTime createdAt;

  const FocusSessionEntity({
    required this.id,
    required this.timerDuration,
    this.ambientSound,
    this.soundVolume,
    required this.completed,
    this.actualDuration,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    timerDuration,
    ambientSound,
    soundVolume,
    completed,
    actualDuration,
    createdAt,
  ];
}

class StreakEntity extends Equatable {
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastActivityDate;

  const StreakEntity({
    required this.currentStreak,
    required this.longestStreak,
    this.lastActivityDate,
  });

  @override
  List<Object?> get props => [currentStreak, longestStreak, lastActivityDate];
}

class AchievementEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String icon;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  const AchievementEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.isUnlocked,
    this.unlockedAt,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    icon,
    isUnlocked,
    unlockedAt,
  ];
}
