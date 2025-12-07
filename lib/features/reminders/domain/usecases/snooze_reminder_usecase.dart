import 'package:dartz/dartz.dart';
import 'package:voclio_app/core/errors/failures.dart';
import '../repositories/reminder_repository.dart';

class SnoozeReminderUseCase {
  final ReminderRepository repository;

  SnoozeReminderUseCase(this.repository);

  Future<Either<Failure, void>> call(String id, int minutes) async {
    return await repository.snoozeReminder(id, minutes);
  }
}
