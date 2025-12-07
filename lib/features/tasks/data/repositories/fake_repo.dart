import 'package:dartz/dartz.dart';
import 'package:voclio_app/core/errors/failures.dart';
import 'package:voclio_app/features/tasks/data/datasources/mock-data-tasks.dart';
import 'package:voclio_app/features/tasks/domain/entities/task_entity.dart';
import 'package:voclio_app/features/tasks/domain/entities/task_extensions.dart';
import 'package:voclio_app/features/tasks/domain/repositories/task_repository.dart';

class FakeRepo implements TaskRepository {
  @override
  Future<void> createTask(TaskEntity task) {
    try {
      mockTasks.add(task);
      return Future.value();
    } catch (e) {
      return Future.value();
    }
  }

  @override
  Future<void> deleteTask(String taskId) {
    try {
      mockTasks.removeWhere((task) => task.id == taskId);
      return Future.value();
    } catch (e) {
      return Future.value();
    }
  }

  @override
  Future<TaskEntity?> getTask(String taskId) {
    try {
      final task = mockTasks.firstWhere((task) => task.id == taskId);
      return Future.value(task);
    } catch (e) {
      return Future.value(null);
    }
  }

  @override
  Future<Either<Failure, List<TaskEntity>>> getTasks() {
    try {
      return Future.value(Right(mockTasks));
    } catch (e) {
      return Future.value(Left(ServerFailure()));
    }
  }

  @override
  Future<void> updateTask(TaskEntity task) {
    try {
      final index = mockTasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        mockTasks[index] = task;
      }
      return Future.value();
    } catch (e) {
      return Future.value();
    }
  }

  @override
  Future<Either<Failure, List<SubtaskEntity>>> getSubtasks(
    String taskId,
  ) async {
    return Right([]);
  }

  @override
  Future<Either<Failure, SubtaskEntity>> createSubtask(
    String taskId,
    String title,
    int order,
  ) async {
    return Right(
      SubtaskEntity(
        id: '1',
        taskId: taskId,
        title: title,
        completed: false,
        order: order,
        createdAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<Either<Failure, void>> updateSubtask(
    String subtaskId,
    String title,
    bool completed,
  ) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> deleteSubtask(String subtaskId) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, List<TaskCategoryEntity>>> getCategories() async {
    return Right([]);
  }

  @override
  Future<Either<Failure, TaskCategoryEntity>> createCategory(
    String name,
    String color,
    String icon,
  ) async {
    return Right(
      TaskCategoryEntity(id: '1', name: name, color: color, icon: icon),
    );
  }

  @override
  Future<Either<Failure, void>> updateCategory(
    String id,
    String name,
    String color,
    String icon,
  ) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> deleteCategory(String id) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, TaskStatisticsEntity>> getTaskStatistics() async {
    return Right(
      TaskStatisticsEntity(
        totalTasks: 0,
        completedTasks: 0,
        pendingTasks: 0,
        overdueTasks: 0,
        completionRate: 0.0,
        categoryBreakdown: {},
      ),
    );
  }
}
