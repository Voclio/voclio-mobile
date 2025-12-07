part of 'settings_cubit.dart';

class SettingsState {
  final bool isLoading;
  final String? error;
  final bool isDarkMode;
  final String language;
  final bool notificationsEnabled;
  final String timezone;

  SettingsState({
    required this.isLoading,
    this.error,
    required this.isDarkMode,
    required this.language,
    required this.notificationsEnabled,
    required this.timezone,
  });

  factory SettingsState.initial() => SettingsState(
    isLoading: false,
    isDarkMode: false,
    language: 'en',
    notificationsEnabled: true,
    timezone: 'UTC',
  );

  SettingsState copyWith({
    bool? isLoading,
    String? error,
    bool? isDarkMode,
    String? language,
    bool? notificationsEnabled,
    String? timezone,
  }) {
    return SettingsState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      language: language ?? this.language,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      timezone: timezone ?? this.timezone,
    );
  }
}
