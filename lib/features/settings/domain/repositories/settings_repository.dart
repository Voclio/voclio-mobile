import 'package:dartz/dartz.dart';
import 'package:voclio_app/core/errors/failures.dart';
import '../entities/user_settings_entity.dart';

abstract class SettingsRepository {
  Future<Either<Failure, UserSettingsEntity>> getSettings();
  Future<Either<Failure, UserSettingsEntity>> updateSettings({
    String? theme,
    String? language,
    String? timezone,
    NotificationPreferences? notificationPreferences,
  });
}
