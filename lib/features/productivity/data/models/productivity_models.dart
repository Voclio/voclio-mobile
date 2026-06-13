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
      actualDuration: json['actual_duration'] ?? json['elapsed_time'],
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
  final int totalPoints;

  StreakModel({
    required this.currentStreak,
    required this.longestStreak,
    this.lastActivityDate,
    this.totalPoints = 0,
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
      totalPoints: json['total_points'] ?? 0,
    );
  }

  StreakEntity toEntity() {
    return StreakEntity(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      lastActivityDate: lastActivityDate,
      totalPoints: totalPoints,
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
  final int progressCurrent;
  final int progressTarget;

  AchievementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.isUnlocked,
    this.unlockedAt,
    this.progressCurrent = 0,
    this.progressTarget = 1,
  });

  factory AchievementModel.fromJson(Map<String, dynamic> json) {
    final type = json['achievement_type']?.toString();
    final earnedAt = json['unlocked_at'] ?? json['earned_at'];

    return AchievementModel(
      id: type ?? (json['achievement_id'] ?? json['id'] ?? '').toString(),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      icon: json['icon']?.toString() ?? _iconForType(type),
      isUnlocked: json['is_unlocked'] == true || earnedAt != null,
      unlockedAt: earnedAt != null
          ? DateTime.tryParse(earnedAt.toString())
          : null,
      progressCurrent: json['progress_current'] ?? 0,
      progressTarget: json['progress_target'] ?? 1,
    );
  }

  static String _iconForType(String? type) {
    switch (type) {
      case 'first_focus':
        return '🎯';
      case 'streak_3':
        return '🔥';
      case 'early_bird':
        return '🌅';
      case 'focus_master':
        return '👑';
      case 'task_warrior':
        return '⚔️';
      case 'night_owl':
        return '🦉';
      default:
        return '🏆';
    }
  }

  AchievementEntity toEntity() {
    return AchievementEntity(
      id: id,
      title: title,
      description: description,
      icon: icon,
      isUnlocked: isUnlocked,
      unlockedAt: unlockedAt,
      progressCurrent: progressCurrent,
      progressTarget: progressTarget,
    );
  }
}
