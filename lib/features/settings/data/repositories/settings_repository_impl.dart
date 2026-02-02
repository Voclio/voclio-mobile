import 'package:dartz/dartz.dart';
import 'package:voclio_app/core/errors/failures.dart';
import '../models/user_settings_model.dart';
import '../../domain/entities/user_settings_entity.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_remote_datasource.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsRemoteDataSource remoteDataSource;

  SettingsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, UserSettingsEntity>> getSettings() async {
    try {
      final settings = await remoteDataSource.getSettings();
      return Right(settings.toEntity());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, UserSettingsEntity>> updateSettings({
    String? theme,
    String? language,
    String? timezone,
    NotificationPreferences? notificationPreferences,
  }) async {
    try {
      UserSettingsModel settings;

      // If only one field is being updated, use the specific endpoint as requested
      if (theme != null &&
          language == null &&
          timezone == null &&
          notificationPreferences == null) {
        settings = await remoteDataSource.updateTheme(theme);
      } else if (language != null &&
          theme == null &&
          timezone == null &&
          notificationPreferences == null) {
        settings = await remoteDataSource.updateLanguage(language);
      } else if (timezone != null &&
          theme == null &&
          language == null &&
          notificationPreferences == null) {
        settings = await remoteDataSource.updateTimezone(timezone);
      } else if (notificationPreferences != null &&
          theme == null &&
          language == null &&
          timezone == null) {
        settings = await remoteDataSource.updateNotifications({
          'push_enabled': notificationPreferences.pushEnabled,
          'email_enabled': notificationPreferences.emailEnabled,
          'whatsapp_enabled': notificationPreferences.whatsappEnabled,
          'email_for_reminders': notificationPreferences.emailForReminders,
          'email_for_tasks': notificationPreferences.emailForTasks,
          'whatsapp_for_reminders':
              notificationPreferences.whatsappForReminders,
        });
      } else {
        // Fallback to bulk update for multiple changes
        final data = <String, dynamic>{};
        if (theme != null) data['theme'] = theme;
        if (language != null) data['language'] = language;
        if (timezone != null) data['timezone'] = timezone;
        if (notificationPreferences != null) {
          data.addAll({
            'push_enabled': notificationPreferences.pushEnabled,
            'email_enabled': notificationPreferences.emailEnabled,
            'whatsapp_enabled': notificationPreferences.whatsappEnabled,
            'email_for_reminders': notificationPreferences.emailForReminders,
            'email_for_tasks': notificationPreferences.emailForTasks,
            'whatsapp_for_reminders':
                notificationPreferences.whatsappForReminders,
          });
        }
        settings = await remoteDataSource.updateSettings(data);
      }

      return Right(settings.toEntity());
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
