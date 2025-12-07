import 'package:dartz/dartz.dart';
import 'package:voclio_app/core/errors/failures.dart';
import 'package:voclio_app/features/reminders/domain/entities/reminder_entity.dart';
import '../../domain/repositories/reminder_repository.dart';
import '../datasources/reminder_remote_datasource.dart';
import '../models/reminder_model.dart';

class ReminderRepositoryImpl implements ReminderRepository {
  final ReminderRemoteDataSource remoteDataSource;

  ReminderRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<ReminderEntity>>> getReminders() async {
    try {
      final reminders = await remoteDataSource.getReminders();
      return Right(reminders.map((r) => r.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<ReminderEntity>>> getUpcomingReminders() async {
    try {
      final reminders = await remoteDataSource.getUpcomingReminders();
      return Right(reminders.map((r) => r.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, ReminderEntity>> getReminder(String id) async {
    try {
      final reminder = await remoteDataSource.getReminder(id);
      return Right(reminder.toEntity());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, ReminderEntity>> createReminder(
    ReminderEntity reminder,
  ) async {
    try {
      final reminderModel = ReminderModel.fromEntity(reminder);
      final created = await remoteDataSource.createReminder(reminderModel);
      return Right(created.toEntity());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, ReminderEntity>> updateReminder(
    ReminderEntity reminder,
  ) async {
    try {
      final reminderModel = ReminderModel.fromEntity(reminder);
      final updated = await remoteDataSource.updateReminder(
        reminder.id,
        reminderModel,
      );
      return Right(updated.toEntity());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> snoozeReminder(String id, int minutes) async {
    try {
      await remoteDataSource.snoozeReminder(id, minutes);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> dismissReminder(String id) async {
    try {
      await remoteDataSource.dismissReminder(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteReminder(String id) async {
    try {
      await remoteDataSource.deleteReminder(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
