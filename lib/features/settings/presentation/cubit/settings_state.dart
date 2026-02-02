part of 'settings_cubit.dart';

class SettingsState {
  final bool isLoading;
  final String? error;
  final String theme;
  final String language;
  final String timezone;
  final bool pushEnabled;
  final bool emailEnabled;
  final bool whatsappEnabled;
  final bool emailForReminders;
  final bool emailForTasks;
  final bool whatsappForReminders;

  SettingsState({
    required this.isLoading,
    this.error,
    required this.theme,
    required this.language,
    required this.timezone,
    required this.pushEnabled,
    required this.emailEnabled,
    required this.whatsappEnabled,
    required this.emailForReminders,
    required this.emailForTasks,
    required this.whatsappForReminders,
  });

  factory SettingsState.initial() => SettingsState(
    isLoading: false,
    theme: 'light',
    language: 'en',
    timezone: 'UTC',
    pushEnabled: true,
    emailEnabled: true,
    whatsappEnabled: false,
    emailForReminders: true,
    emailForTasks: true,
    whatsappForReminders: false,
  );

  SettingsState copyWith({
    bool? isLoading,
    String? error,
    String? theme,
    String? language,
    String? timezone,
    bool? pushEnabled,
    bool? emailEnabled,
    bool? whatsappEnabled,
    bool? emailForReminders,
    bool? emailForTasks,
    bool? whatsappForReminders,
  }) {
    return SettingsState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      theme: theme ?? this.theme,
      language: language ?? this.language,
      timezone: timezone ?? this.timezone,
      pushEnabled: pushEnabled ?? this.pushEnabled,
      emailEnabled: emailEnabled ?? this.emailEnabled,
      whatsappEnabled: whatsappEnabled ?? this.whatsappEnabled,
      emailForReminders: emailForReminders ?? this.emailForReminders,
      emailForTasks: emailForTasks ?? this.emailForTasks,
      whatsappForReminders: whatsappForReminders ?? this.whatsappForReminders,
    );
  }
}
