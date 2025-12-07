import '../../domain/entities/user_settings_entity.dart';

class UserSettingsModel {
  final String theme;
  final String language;
  final String timezone;
  final NotificationPreferencesModel notificationPreferences;

  UserSettingsModel({
    required this.theme,
    required this.language,
    required this.timezone,
    required this.notificationPreferences,
  });

  factory UserSettingsModel.fromJson(Map<String, dynamic> json) {
    return UserSettingsModel(
      theme: json['theme'] ?? 'light',
      language: json['language'] ?? 'en',
      timezone: json['timezone'] ?? 'UTC',
      notificationPreferences:
          json['notification_preferences'] != null
              ? NotificationPreferencesModel.fromJson(
                json['notification_preferences'],
              )
              : NotificationPreferencesModel(
                taskReminders: true,
                achievements: true,
                productivityTips: true,
              ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'theme': theme,
      'language': language,
      'timezone': timezone,
      'notification_preferences': notificationPreferences.toJson(),
    };
  }

  UserSettingsEntity toEntity() {
    return UserSettingsEntity(
      theme: theme,
      language: language,
      timezone: timezone,
      notificationPreferences: notificationPreferences.toEntity(),
    );
  }
}

class NotificationPreferencesModel {
  final bool taskReminders;
  final bool achievements;
  final bool productivityTips;

  NotificationPreferencesModel({
    required this.taskReminders,
    required this.achievements,
    required this.productivityTips,
  });

  factory NotificationPreferencesModel.fromJson(Map<String, dynamic> json) {
    return NotificationPreferencesModel(
      taskReminders: json['task_reminders'] ?? true,
      achievements: json['achievements'] ?? true,
      productivityTips: json['productivity_tips'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'task_reminders': taskReminders,
      'achievements': achievements,
      'productivity_tips': productivityTips,
    };
  }

  NotificationPreferences toEntity() {
    return NotificationPreferences(
      taskReminders: taskReminders,
      achievements: achievements,
      productivityTips: productivityTips,
    );
  }
}
