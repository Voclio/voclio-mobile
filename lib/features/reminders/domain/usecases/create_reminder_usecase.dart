import 'package:dartz/dartz.dart';
import 'package:voclio_app/core/errors/failures.dart';
import '../entities/reminder_entity.dart';
import '../repositories/reminder_repository.dart';

class CreateReminderUseCase {
  final ReminderRepository repository;

  CreateReminderUseCase(this.repository);

  Future<Either<Failure, ReminderEntity>> call(ReminderEntity reminder) async {
    return await repository.createReminder(reminder);
  }
}
