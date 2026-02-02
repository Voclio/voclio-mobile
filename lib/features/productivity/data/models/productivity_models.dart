import 'package:voclio_app/features/productivity/domain/entities/productivity_entities.dart';

class FocusSessionModel {
  final String id;
  final int timerDuration;
  final String? ambientSound;
  final int? soundVolume;
  final bool completed;
  final int? actualDuration;
  final DateTime createdAt;

  FocusSessionModel({
    required this.id,
    required this.timerDuration,
    this.ambientSound,
    this.soundVolume,
    required this.completed,
    this.actualDuration,
    required this.createdAt,
  });

  factory FocusSessionModel.fromJson(Map<String, dynamic> json) {
    return FocusSessionModel(
      id: (json['session_id'] ?? json['id'] ?? '').toString(),
      timerDuration: json['timer_duration'] ?? 25,
      ambientSound: json['ambient_sound'],
      soundVolume: json['sound_volume'],
      completed: (json['completed'] ?? false) || json['status'] == 'completed',
      actualDuration: json['actual_duration'],
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timer_duration': timerDuration,
      if (ambientSound != null) 'ambient_sound': ambientSound,
      if (soundVolume != null) 'sound_volume': soundVolume,
    };
  }

  FocusSessionEntity toEntity() {
    return FocusSessionEntity(
      id: id,
      timerDuration: timerDuration,
      ambientSound: ambientSound,
      soundVolume: soundVolume,
      completed: completed,
      actualDuration: actualDuration,
      createdAt: createdAt,
    );
  }
}

class StreakModel {
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastActivityDate;

  StreakModel({
    required this.currentStreak,
    required this.longestStreak,
    this.lastActivityDate,
  });

  factory StreakModel.fromJson(Map<String, dynamic> json) {
    return StreakModel(
      currentStreak: json['current_streak'] ?? 0,
      longestStreak: json['longest_streak'] ?? 0,
      lastActivityDate:
          (json['last_activity_date'] ?? json['streak_date']) != null
              ? DateTime.parse(
                json['last_activity_date'] ?? json['streak_date'],
              )
              : null,
    );
  }

  StreakEntity toEntity() {
    return StreakEntity(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      lastActivityDate: lastActivityDate,
    );
  }
}

class AchievementModel {
  final String id;
  final String title;
  final String description;
  final String icon;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  AchievementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.isUnlocked,
    this.unlockedAt,
  });

  factory AchievementModel.fromJson(Map<String, dynamic> json) {
    return AchievementModel(
      id: json['achievement_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? '🏆',
      isUnlocked: json['is_unlocked'] ?? false,
      unlockedAt:
          json['unlocked_at'] != null
              ? DateTime.parse(json['unlocked_at'])
              : null,
    );
  }

  AchievementEntity toEntity() {
    return AchievementEntity(
      id: id,
      title: title,
      description: description,
      icon: icon,
      isUnlocked: isUnlocked,
      unlockedAt: unlockedAt,
    );
  }
}
