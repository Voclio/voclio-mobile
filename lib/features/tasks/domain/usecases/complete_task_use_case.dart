import 'package:dartz/dartz.dart';
import 'package:voclio_app/core/errors/failures.dart';
import 'package:voclio_app/features/tasks/domain/repositories/task_repository.dart';

class CompleteTaskUseCase {
  final TaskRepository taskRepository;

  CompleteTaskUseCase(this.taskRepository);

  Future<Either<Failure, void>> call(String taskId) async {
    return await taskRepository.completeTask(taskId);
  }
}
