import 'package:dartz/dartz.dart';
import 'package:voclio_app/core/errors/failures.dart';
import '../repositories/reminder_repository.dart';

class DismissReminderUseCase {
  final ReminderRepository repository;

  DismissReminderUseCase(this.repository);

  Future<Either<Failure, void>> call(String id) async {
    return await repository.dismissReminder(id);
  }
}
