import 'package:dartz/dartz.dart';
import 'package:voclio_app/core/errors/failures.dart';
import 'package:voclio_app/features/tasks/domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';
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
      return Left(ServerFailure());
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
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteTask(String id) async {
    try {
      await remoteDataSource.deleteTask(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
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
      return Left(ServerFailure()); // Defined in core/error/failures.dart
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
}
