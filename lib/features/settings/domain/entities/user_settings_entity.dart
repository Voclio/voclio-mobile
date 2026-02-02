import 'package:equatable/equatable.dart';

class UserSettingsEntity extends Equatable {
  final String theme;
  final String language;
  final String timezone;
  final NotificationPreferences notificationPreferences;

  const UserSettingsEntity({
    required this.theme,
    required this.language,
    required this.timezone,
    required this.notificationPreferences,
  });

  @override
  List<Object?> get props => [
    theme,
    language,
    timezone,
    notificationPreferences,
  ];
}

class NotificationPreferences extends Equatable {
  final bool pushEnabled;
  final bool emailEnabled;
  final bool whatsappEnabled;
  final bool emailForReminders;
  final bool emailForTasks;
  final bool whatsappForReminders;

  const NotificationPreferences({
    required this.pushEnabled,
    required this.emailEnabled,
    required this.whatsappEnabled,
    required this.emailForReminders,
    required this.emailForTasks,
    required this.whatsappForReminders,
  });

  @override
  List<Object?> get props => [
    pushEnabled,
    emailEnabled,
    whatsappEnabled,
    emailForReminders,
    emailForTasks,
    whatsappForReminders,
  ];
}
