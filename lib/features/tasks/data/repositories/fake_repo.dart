import 'package:dartz/dartz.dart';
import 'package:voclio_app/core/errors/failures.dart';
import 'package:voclio_app/features/tasks/data/datasources/mock-data-tasks.dart';
import 'package:voclio_app/features/tasks/domain/entities/task_entity.dart';
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
}
