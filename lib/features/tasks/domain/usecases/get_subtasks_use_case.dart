import 'package:dartz/dartz.dart';
import 'package:voclio_app/core/errors/failures.dart';
import 'package:voclio_app/features/tasks/domain/entities/task_extensions.dart';
import 'package:voclio_app/features/tasks/domain/repositories/task_repository.dart';

class GetSubtasksUseCase {
  final TaskRepository taskRepository;

  GetSubtasksUseCase(this.taskRepository);

  Future<Either<Failure, List<SubtaskEntity>>> call(String taskId) {
    return taskRepository.getSubtasks(taskId);
  }
}
