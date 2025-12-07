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
  final bool taskReminders;
  final bool achievements;
  final bool productivityTips;

  const NotificationPreferences({
    required this.taskReminders,
    required this.achievements,
    required this.productivityTips,
  });

  @override
  List<Object?> get props => [taskReminders, achievements, productivityTips];
}
