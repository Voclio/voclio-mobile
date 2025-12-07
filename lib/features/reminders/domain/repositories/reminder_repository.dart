import 'package:dartz/dartz.dart';
import 'package:voclio_app/core/errors/failures.dart';
import '../entities/reminder_entity.dart';

abstract class ReminderRepository {
  Future<Either<Failure, List<ReminderEntity>>> getReminders();
  Future<Either<Failure, List<ReminderEntity>>> getUpcomingReminders();
  Future<Either<Failure, ReminderEntity>> getReminder(String id);
  Future<Either<Failure, ReminderEntity>> createReminder(
    ReminderEntity reminder,
  );
  Future<Either<Failure, ReminderEntity>> updateReminder(
    ReminderEntity reminder,
  );
  Future<Either<Failure, void>> snoozeReminder(String id, int minutes);
  Future<Either<Failure, void>> dismissReminder(String id);
  Future<Either<Failure, void>> deleteReminder(String id);
}
