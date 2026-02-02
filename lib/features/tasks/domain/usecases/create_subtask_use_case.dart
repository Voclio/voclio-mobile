import 'package:dartz/dartz.dart';
import 'package:voclio_app/core/errors/failures.dart';
import 'package:voclio_app/features/tasks/domain/entities/task_extensions.dart';
import 'package:voclio_app/features/tasks/domain/repositories/task_repository.dart';

class CreateSubtaskUseCase {
  final TaskRepository taskRepository;

  CreateSubtaskUseCase(this.taskRepository);

  Future<Either<Failure, SubtaskEntity>> call(String taskId, String title, int order) async {
    return await taskRepository.createSubtask(taskId, title, order);
  }
}
