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
    // Check if nested in 'settings' or direct
    final settingsMap = json['settings'] ?? json;

    return UserSettingsModel(
      theme: settingsMap['theme'] ?? 'light',
      language: settingsMap['language'] ?? 'en',
      timezone: settingsMap['timezone'] ?? 'UTC',
      notificationPreferences: NotificationPreferencesModel.fromJson(
        settingsMap,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'theme': theme,
      'language': language,
      'timezone': timezone,
      ...notificationPreferences.toJson(),
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
  final bool pushEnabled;
  final bool emailEnabled;
  final bool whatsappEnabled;
  final bool emailForReminders;
  final bool emailForTasks;
  final bool whatsappForReminders;

  NotificationPreferencesModel({
    required this.pushEnabled,
    required this.emailEnabled,
    required this.whatsappEnabled,
    required this.emailForReminders,
    required this.emailForTasks,
    required this.whatsappForReminders,
  });

  factory NotificationPreferencesModel.fromJson(Map<String, dynamic> json) {
    return NotificationPreferencesModel(
      pushEnabled: json['push_enabled'] ?? true,
      emailEnabled: json['email_enabled'] ?? true,
      whatsappEnabled: json['whatsapp_enabled'] ?? false,
      emailForReminders: json['email_for_reminders'] ?? true,
      emailForTasks: json['email_for_tasks'] ?? true,
      whatsappForReminders: json['whatsapp_for_reminders'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'push_enabled': pushEnabled,
      'email_enabled': emailEnabled,
      'whatsapp_enabled': whatsappEnabled,
      'email_for_reminders': emailForReminders,
      'email_for_tasks': emailForTasks,
      'whatsapp_for_reminders': whatsappForReminders,
    };
  }

  NotificationPreferences toEntity() {
    return NotificationPreferences(
      pushEnabled: pushEnabled,
      emailEnabled: emailEnabled,
      whatsappEnabled: whatsappEnabled,
      emailForReminders: emailForReminders,
      emailForTasks: emailForTasks,
      whatsappForReminders: whatsappForReminders,
    );
  }
}
