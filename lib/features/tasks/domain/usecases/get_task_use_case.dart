import 'package:voclio_app/features/tasks/domain/entities/task_entity.dart';
import 'package:voclio_app/features/tasks/domain/repositories/task_repository.dart';

class GetTaskUseCase {
  final TaskRepository taskRepository;

  GetTaskUseCase(this.taskRepository);

  Future<TaskEntity?> call(String taskId) async {
    return taskRepository.getTask(taskId);
  }
}
