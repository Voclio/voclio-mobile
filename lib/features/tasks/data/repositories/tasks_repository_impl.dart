import 'package:dartz/dartz.dart';
import 'package:voclio_app/core/errors/failures.dart';
import 'package:voclio_app/features/tasks/domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';
import '../../domain/entities/task_extensions.dart';
import '../datasources/task_remote_data_source.dart';
import '../models/task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource remoteDataSource;

  TaskRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, TaskEntity>> createTask(TaskEntity task) async {
    try {
      // Convert Entity -> Model before sending to DataSource
      final taskModel = TaskModel(
        id: task.id,
        title: task.title,
        date: task.date,
        createdAt: task.createdAt,
        description: task.description,
        isDone: task.isDone,
        priority: task.priority,
        subtasks: task.subtasks,
        tags: task.tags,
        relatedNoteId: task.relatedNoteId,
      );

      final result = await remoteDataSource.addTask(taskModel);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, TaskEntity>> updateTask(TaskEntity task) async {
    try {
      // Manual conversion Entity -> Model
      // (Or you can add a toModel() method in your Entity extensions)
      final taskModel = TaskModel(
        id: task.id,
        title: task.title,
        date: task.date,
        createdAt: task.createdAt,
        description: task.description,
        isDone: task.isDone,
        priority: task.priority,
        subtasks: task.subtasks,
        tags: task.tags,
        relatedNoteId: task.relatedNoteId,
      );

      final result = await remoteDataSource.updateTask(taskModel);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTask(String id) async {
    try {
      await remoteDataSource.deleteTask(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TaskEntity>>> getTasks() async {
    try {
      final remoteTasks = await remoteDataSource.getTasks();
      final taskEntities =
          remoteTasks
              .map(
                (taskModel) => TaskEntity(
                  id: taskModel.id,
                  title: taskModel.title,
                  date: taskModel.date,
                  createdAt: taskModel.createdAt,
                  description: taskModel.description,
                  isDone: taskModel.isDone,
                  priority: taskModel.priority,
                  subtasks: taskModel.subtasks,
                  tags: taskModel.tags,
                  relatedNoteId: taskModel.relatedNoteId,
                ),
              )
              .toList();
      return Right(taskEntities);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TaskEntity>>> getTasksByCategory(
    String categoryId,
  ) async {
    try {
      final remoteTasks = await remoteDataSource.getTasksByCategory(categoryId);
      final taskEntities =
          remoteTasks
              .map(
                (taskModel) => TaskEntity(
                  id: taskModel.id,
                  title: taskModel.title,
                  date: taskModel.date,
                  createdAt: taskModel.createdAt,
                  description: taskModel.description,
                  isDone: taskModel.isDone,
                  priority: taskModel.priority,
                  subtasks: taskModel.subtasks,
                  tags: taskModel.tags,
                  relatedNoteId: taskModel.relatedNoteId,
                ),
              )
              .toList();
      return Right(taskEntities);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<TaskEntity?> getTask(String taskId) async {
    try {
      final taskModel = await remoteDataSource.getTask(taskId);
      if (taskModel == null) return null;
      return TaskEntity(
        id: taskModel.id,
        title: taskModel.title,
        date: taskModel.date,
        createdAt: taskModel.createdAt,
        description: taskModel.description,
        isDone: taskModel.isDone,
        priority: taskModel.priority,
        subtasks: taskModel.subtasks,
        tags: taskModel.tags,
        relatedNoteId: taskModel.relatedNoteId,
      );
    } catch (e) {
      return null; // Or throw a specific failure if needed
    }
  }

  @override
  Future<Either<Failure, void>> completeTask(String taskId) async {
    try {
      await remoteDataSource.completeTask(taskId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // Subtasks
  @override
  Future<Either<Failure, List<SubtaskEntity>>> getSubtasks(
    String taskId,
  ) async {
    try {
      final subtasks = await remoteDataSource.getSubtasks(taskId);
      return Right(subtasks.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SubtaskEntity>> createSubtask(
    String taskId,
    String title,
    int order,
  ) async {
    try {
      final subtask = await remoteDataSource.createSubtask(
        taskId,
        title,
        order,
      );
      return Right(subtask.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateSubtask(
    String taskId,
    String subtaskId,
    String title,
    bool completed,
  ) async {
    try {
      await remoteDataSource.updateSubtask(taskId, subtaskId, title, completed);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteSubtask(String taskId, String subtaskId) async {
    try {
      await remoteDataSource.deleteSubtask(taskId, subtaskId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // Categories
  @override
  Future<Either<Failure, List<TaskCategoryEntity>>> getCategories() async {
    try {
      final categories = await remoteDataSource.getCategories();
      return Right(categories.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, TaskCategoryEntity>> createCategory(
    String name,
    String color,
    String icon,
  ) async {
    try {
      final category = await remoteDataSource.createCategory(name, color, icon);
      return Right(category.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateCategory(
    String id,
    String name,
    String color,
    String icon,
  ) async {
    try {
      await remoteDataSource.updateCategory(id, name, color, icon);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCategory(String id) async {
    try {
      await remoteDataSource.deleteCategory(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // Statistics
  @override
  Future<Either<Failure, TaskStatisticsEntity>> getTaskStatistics() async {
    try {
      final stats = await remoteDataSource.getTaskStatistics();
      return Right(stats.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
