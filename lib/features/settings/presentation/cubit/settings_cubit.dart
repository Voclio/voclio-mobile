import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voclio_app/features/settings/domain/entities/user_settings_entity.dart';
import 'package:voclio_app/features/settings/domain/usecases/settings_usecases.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final GetSettingsUseCase getSettingsUseCase;
  final UpdateSettingsUseCase updateSettingsUseCase;
  final SharedPreferences prefs;

  SettingsCubit({
    required this.getSettingsUseCase,
    required this.updateSettingsUseCase,
    required this.prefs,
  }) : super(SettingsState.initial());

  Future<void> loadSettings() async {
    emit(state.copyWith(isLoading: true));
    final result = await getSettingsUseCase();

    result.fold(
      (failure) => emit(
        state.copyWith(isLoading: false, error: 'Failed to load settings'),
      ),
      (settings) {
        emit(
          state.copyWith(
            isLoading: false,
            theme: settings.theme,
            language: settings.language,
            timezone: settings.timezone,
            pushEnabled: settings.notificationPreferences.pushEnabled,
            emailEnabled: settings.notificationPreferences.emailEnabled,
            whatsappEnabled: settings.notificationPreferences.whatsappEnabled,
            emailForReminders:
                settings.notificationPreferences.emailForReminders,
            emailForTasks: settings.notificationPreferences.emailForTasks,
            whatsappForReminders:
                settings.notificationPreferences.whatsappForReminders,
          ),
        );
      },
    );
  }

  Future<void> updateTheme(String theme) async {
    emit(state.copyWith(isLoading: true));
    final result = await updateSettingsUseCase(theme: theme);

    result.fold(
      (failure) => emit(
        state.copyWith(isLoading: false, error: 'Failed to update theme'),
      ),
      (settings) => emit(state.copyWith(isLoading: false, theme: theme)),
    );
  }

  Future<void> updateLanguage(String lang) async {
    emit(state.copyWith(isLoading: true));
    final result = await updateSettingsUseCase(language: lang);

    result.fold(
      (failure) => emit(
        state.copyWith(isLoading: false, error: 'Failed to update language'),
      ),
      (settings) => emit(state.copyWith(isLoading: false, language: lang)),
    );
  }

  Future<void> updateTimezone(String tz) async {
    emit(state.copyWith(isLoading: true));
    final result = await updateSettingsUseCase(timezone: tz);

    result.fold(
      (failure) => emit(
        state.copyWith(isLoading: false, error: 'Failed to update timezone'),
      ),
      (settings) => emit(state.copyWith(isLoading: false, timezone: tz)),
    );
  }

  Future<void> updateNotificationPreference({
    bool? pushEnabled,
    bool? emailEnabled,
    bool? whatsappEnabled,
    bool? emailForReminders,
    bool? emailForTasks,
    bool? whatsappForReminders,
  }) async {
    final currentPrefs = NotificationPreferences(
      pushEnabled: pushEnabled ?? state.pushEnabled,
      emailEnabled: emailEnabled ?? state.emailEnabled,
      whatsappEnabled: whatsappEnabled ?? state.whatsappEnabled,
      emailForReminders: emailForReminders ?? state.emailForReminders,
      emailForTasks: emailForTasks ?? state.emailForTasks,
      whatsappForReminders: whatsappForReminders ?? state.whatsappForReminders,
    );

    emit(state.copyWith(isLoading: true));
    final result = await updateSettingsUseCase(
      notificationPreferences: currentPrefs,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          isLoading: false,
          error: 'Failed to update notification preferences',
        ),
      ),
      (settings) => emit(
        state.copyWith(
          isLoading: false,
          pushEnabled: currentPrefs.pushEnabled,
          emailEnabled: currentPrefs.emailEnabled,
          whatsappEnabled: currentPrefs.whatsappEnabled,
          emailForReminders: currentPrefs.emailForReminders,
          emailForTasks: currentPrefs.emailForTasks,
          whatsappForReminders: currentPrefs.whatsappForReminders,
        ),
      ),
    );
  }
}
