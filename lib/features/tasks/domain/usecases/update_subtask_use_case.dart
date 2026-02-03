import 'package:dartz/dartz.dart';
import 'package:voclio_app/core/errors/failures.dart';
import 'package:voclio_app/features/tasks/domain/repositories/task_repository.dart';

class UpdateSubtaskUseCase {
  final TaskRepository taskRepository;

  UpdateSubtaskUseCase(this.taskRepository);

  Future<Either<Failure, void>> call(String taskId, String subtaskId, String title, bool completed) async {
    return await taskRepository.updateSubtask(taskId, subtaskId, title, completed);
  }
}
