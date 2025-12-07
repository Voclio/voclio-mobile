import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final SharedPreferences prefs;

  SettingsCubit({required this.prefs}) : super(SettingsState.initial());

  Future<void> loadSettings() async {
    emit(state.copyWith(isLoading: true));
    try {
      final isDarkMode = prefs.getBool('isDarkMode') ?? false;
      final language = prefs.getString('language') ?? 'en';
      final notificationsEnabled =
          prefs.getBool('notificationsEnabled') ?? true;
      final timezone = prefs.getString('timezone') ?? 'UTC';

      emit(
        state.copyWith(
          isLoading: false,
          isDarkMode: isDarkMode,
          language: language,
          notificationsEnabled: notificationsEnabled,
          timezone: timezone,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> toggleTheme(bool isDark) async {
    await prefs.setBool('isDarkMode', isDark);
    emit(state.copyWith(isDarkMode: isDark));
  }

  Future<void> changeLanguage(String lang) async {
    await prefs.setString('language', lang);
    emit(state.copyWith(language: lang));
  }

  Future<void> toggleNotifications(bool enabled) async {
    await prefs.setBool('notificationsEnabled', enabled);
    emit(state.copyWith(notificationsEnabled: enabled));
  }

  Future<void> changeTimezone(String tz) async {
    await prefs.setString('timezone', tz);
    emit(state.copyWith(timezone: tz));
  }
}
