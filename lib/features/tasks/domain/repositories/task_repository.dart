import 'package:dartz/dartz.dart';
import 'package:voclio_app/core/errors/failures.dart';
import 'package:voclio_app/features/tasks/domain/entities/task_entity.dart';

abstract class TaskRepository {
  Future<void> createTask(TaskEntity task);

  Future<void> updateTask(TaskEntity task);

  Future<void> deleteTask(String taskId);

  Future<TaskEntity?> getTask(String taskId);

  Future<Either<Failure, List<TaskEntity>>> getTasks();
}
