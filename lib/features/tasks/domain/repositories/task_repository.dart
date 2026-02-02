import 'package:dartz/dartz.dart';
import 'package:voclio_app/core/errors/failures.dart';
import 'package:voclio_app/features/tasks/domain/entities/task_entity.dart';
import '../entities/task_extensions.dart';

abstract class TaskRepository {
  Future<Either<Failure, TaskEntity>> createTask(TaskEntity task);

  Future<Either<Failure, TaskEntity>> updateTask(TaskEntity task);

  Future<Either<Failure, void>> deleteTask(String taskId);

  Future<TaskEntity?> getTask(String taskId);

  Future<Either<Failure, void>> completeTask(String taskId);

  Future<Either<Failure, List<TaskEntity>>> getTasks();
  Future<Either<Failure, List<TaskEntity>>> getTasksByCategory(
    String categoryId,
  );

  // Subtasks
  Future<Either<Failure, List<SubtaskEntity>>> getSubtasks(String taskId);
  Future<Either<Failure, SubtaskEntity>> createSubtask(
    String taskId,
    String title,
    int order,
  );
  Future<Either<Failure, void>> updateSubtask(
    String subtaskId,
    String title,
    bool completed,
  );
  Future<Either<Failure, void>> deleteSubtask(String subtaskId);

  // Categories
  Future<Either<Failure, List<TaskCategoryEntity>>> getCategories();
  Future<Either<Failure, TaskCategoryEntity>> createCategory(
    String name,
    String color,
    String icon,
  );
  Future<Either<Failure, void>> updateCategory(
    String id,
    String name,
    String color,
    String icon,
  );
  Future<Either<Failure, void>> deleteCategory(String id);

  // Statistics
  Future<Either<Failure, TaskStatisticsEntity>> getTaskStatistics();
}
