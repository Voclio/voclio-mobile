import 'package:dio/dio.dart';
import '../models/task_model.dart';

abstract class TaskRemoteDataSource {
  Future<List<TaskModel>> getTasks();
  Future<TaskModel> addTask(TaskModel task);
  Future<TaskModel> updateTask(TaskModel task);
  Future<void> deleteTask(String id);
  Future<TaskModel?> getTask(String taskId);
}

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  final Dio dio;

  TaskRemoteDataSourceImpl(this.dio);

  @override
  Future<List<TaskModel>> getTasks() async {
    try {
      // Replace with your actual endpoint
      final response = await dio.get('/tasks');

      return (response.data as List).map((e) => TaskModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception(); // Throw custom ServerException here
    }
  }

  @override
  Future<TaskModel> addTask(TaskModel task) async {
    final response = await dio.post('/tasks', data: task.toJson());
    return TaskModel.fromJson(response.data);
  }

  @override
  Future<TaskModel> updateTask(TaskModel task) async {
    // Usually PUT or PATCH
    final response = await dio.put('/tasks/${task.id}', data: task.toJson());
    return TaskModel.fromJson(response.data);
  }

  @override
  Future<void> deleteTask(String id) async {
    await dio.delete('/tasks/$id');
  }

  @override
  Future<TaskModel?> getTask(String taskId) async {
    final response = await dio.get('/tasks/$taskId');
    return TaskModel.fromJson(response.data);
  }
}
