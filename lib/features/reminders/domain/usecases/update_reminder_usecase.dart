import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/reminder_entity.dart';
import '../repositories/reminder_repository.dart';

class UpdateReminderUseCase {
  final ReminderRepository repository;

  UpdateReminderUseCase(this.repository);

  Future<Either<Failure, void>> call(ReminderEntity reminder) async {
    return await repository.updateReminder(reminder);
  }
}
