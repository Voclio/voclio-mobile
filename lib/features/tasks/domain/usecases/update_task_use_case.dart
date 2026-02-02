import 'package:dartz/dartz.dart';
import 'package:voclio_app/core/errors/failures.dart';
import 'package:voclio_app/features/tasks/domain/entities/task_entity.dart';
import 'package:voclio_app/features/tasks/domain/repositories/task_repository.dart';

class UpdateTaskUseCase {
  final TaskRepository taskRepository;

  UpdateTaskUseCase(this.taskRepository);

  Future<Either<Failure, TaskEntity>> call(TaskEntity task) async {
    return await taskRepository.updateTask(task);
  }
}
