import 'package:dartz/dartz.dart';
import 'package:voclio_app/core/errors/failures.dart';
import '../entities/user_settings_entity.dart';
import '../repositories/settings_repository.dart';

class GetSettingsUseCase {
  final SettingsRepository repository;

  GetSettingsUseCase(this.repository);

  Future<Either<Failure, UserSettingsEntity>> call() async {
    return await repository.getSettings();
  }
}

class UpdateSettingsUseCase {
  final SettingsRepository repository;

  UpdateSettingsUseCase(this.repository);

  Future<Either<Failure, UserSettingsEntity>> call({
    String? theme,
    String? language,
    String? timezone,
    NotificationPreferences? notificationPreferences,
  }) async {
    return await repository.updateSettings(
      theme: theme,
      language: language,
      timezone: timezone,
      notificationPreferences: notificationPreferences,
    );
  }
}
