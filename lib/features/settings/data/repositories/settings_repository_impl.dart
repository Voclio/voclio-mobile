import 'package:dartz/dartz.dart';
import 'package:voclio_app/core/errors/failures.dart';
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
      final data = <String, dynamic>{};
      if (theme != null) data['theme'] = theme;
      if (language != null) data['language'] = language;
      if (timezone != null) data['timezone'] = timezone;
      if (notificationPreferences != null) {
        data['notification_preferences'] = {
          'task_reminders': notificationPreferences.taskReminders,
          'achievements': notificationPreferences.achievements,
          'productivity_tips': notificationPreferences.productivityTips,
        };
      }

      final settings = await remoteDataSource.updateSettings(data);
      return Right(settings.toEntity());
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
