import 'package:dartz/dartz.dart';
import 'package:voclio_app/core/errors/failures.dart';
import '../entities/reminder_entity.dart';
import '../repositories/reminder_repository.dart';

class GetRemindersUseCase {
  final ReminderRepository repository;

  GetRemindersUseCase(this.repository);

  Future<Either<Failure, List<ReminderEntity>>> call() async {
    return await repository.getReminders();
  }
}
