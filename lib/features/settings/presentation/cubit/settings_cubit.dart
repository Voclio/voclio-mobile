import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voclio_app/core/app/language_controller.dart';
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
      (settings) async {
        const language = 'en';
        if (settings.language != language) {
          await updateSettingsUseCase(language: language);
        }
        await LanguageController.instance.changeLanguage(const Locale(language));
        emit(
          state.copyWith(
            isLoading: false,
            language: language,
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

  Future<void> updateTimezone(String tz) async {
    emit(state.copyWith(isLoading: true));
    final result = await updateSettingsUseCase(timezone: tz);

    result.fold(
      (failure) => emit(
        state.copyWith(isLoading: false, error: 'Failed to update timezone'),
      ),
      (settings) => emit(
        state.copyWith(isLoading: false, timezone: tz, error: null),
      ),
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
          error: null,
        ),
      ),
    );
  }

  void clearError() {
    emit(state.copyWith(error: null));
  }
}
