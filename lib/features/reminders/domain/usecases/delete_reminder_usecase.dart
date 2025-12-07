import 'package:dartz/dartz.dart';
import 'package:voclio_app/core/errors/failures.dart';
import '../repositories/reminder_repository.dart';

class DeleteReminderUseCase {
  final ReminderRepository repository;

  DeleteReminderUseCase(this.repository);

  Future<Either<Failure, void>> call(String id) async {
    return await repository.deleteReminder(id);
  }
}
