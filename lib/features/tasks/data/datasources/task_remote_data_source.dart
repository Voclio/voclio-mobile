import 'package:dio/dio.dart';
import 'package:voclio_app/core/api/api_client.dart';
import 'package:voclio_app/core/api/api_endpoints.dart';
import '../models/task_model.dart';
import '../models/task_extensions_models.dart';

abstract class TaskRemoteDataSource {
  Future<List<TaskModel>> getTasks();
  Future<TaskModel> addTask(TaskModel task);
  Future<TaskModel> updateTask(TaskModel task);
  Future<void> deleteTask(String id);
  Future<TaskModel?> getTask(String taskId);
  Future<void> completeTask(String id);

  // Subtasks methods
  Future<List<SubtaskModel>> getSubtasks(String taskId);
  Future<SubtaskModel> createSubtask(String taskId, String title, int order);
  Future<void> updateSubtask(String subtaskId, String title, bool completed);
  Future<void> deleteSubtask(String subtaskId);

  // Categories methods
  Future<List<TaskCategoryModel>> getCategories();
  Future<TaskCategoryModel> createCategory(
    String name,
    String color,
    String icon,
  );
  Future<void> updateCategory(
    String id,
    String name,
    String color,
    String icon,
  );
  Future<void> deleteCategory(String id);

  // Statistics
  Future<TaskStatisticsModel> getTaskStatistics();
}

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  final Dio dio;
  final ApiClient apiClient;

  TaskRemoteDataSourceImpl(this.dio, {required this.apiClient});

  @override
  Future<List<TaskModel>> getTasks() async {
    try {
      final response = await apiClient.get(ApiEndpoints.tasks);
      // The response structure is { data: { tasks: [...] } }
      final List<dynamic> tasksData = response.data['data']['tasks'] ?? [];
      return tasksData
          .map((e) => TaskModel.fromJson(e))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch tasks: $e');
    }
  }

  @override
  Future<TaskModel> addTask(TaskModel task) async {
    final response = await apiClient.post(
      ApiEndpoints.tasks,
      data: task.toJson(),
    );
    return TaskModel.fromJson(response.data['data']);
  }

  @override
  Future<TaskModel> updateTask(TaskModel task) async {
    final response = await apiClient.put(
      ApiEndpoints.taskById(task.id),
      data: task.toJson(),
    );
    return TaskModel.fromJson(response.data['data']);
  }

  @override
  Future<void> deleteTask(String id) async {
    await apiClient.delete(ApiEndpoints.taskById(id));
  }

  @override
  Future<TaskModel?> getTask(String taskId) async {
    final response = await apiClient.get(ApiEndpoints.taskById(taskId));
    return TaskModel.fromJson(response.data['data']);
  }

  @override
  Future<void> completeTask(String id) async {
    try {
      await apiClient.post(ApiEndpoints.completeTask(id));
    } catch (e) {
      throw Exception('Failed to complete task: $e');
    }
  }

  // ========== Subtasks ==========
  @override
  Future<List<SubtaskModel>> getSubtasks(String taskId) async {
    try {
      final response = await apiClient.get(ApiEndpoints.subtasks(taskId));
      final List<dynamic> data = response.data['data'];
      return data.map((json) => SubtaskModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch subtasks: $e');
    }
  }

  @override
  Future<SubtaskModel> createSubtask(
    String taskId,
    String title,
    int order,
  ) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.taskSubtasks(taskId),
        data: {'title': title, 'order': order},
      );
      return SubtaskModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to create subtask: $e');
    }
  }

  @override
  Future<void> updateSubtask(
    String subtaskId,
    String title,
    bool completed,
  ) async {
    try {
      await apiClient.put(
        ApiEndpoints.subtaskById(subtaskId),
        data: {'title': title, 'completed': completed},
      );
    } catch (e) {
      throw Exception('Failed to update subtask: $e');
    }
  }

  @override
  Future<void> deleteSubtask(String subtaskId) async {
    try {
      await apiClient.delete(ApiEndpoints.subtaskById(subtaskId));
    } catch (e) {
      throw Exception('Failed to delete subtask: $e');
    }
  }

  // ========== Categories ==========
  @override
  Future<List<TaskCategoryModel>> getCategories() async {
    try {
      final response = await apiClient.get(ApiEndpoints.taskCategories);
      final List<dynamic> data = response.data['data'];
      return data.map((json) => TaskCategoryModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }

  @override
  Future<TaskCategoryModel> createCategory(
    String name,
    String color,
    String icon,
  ) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.taskCategories,
        data: {'name': name, 'color': color, 'icon': icon},
      );
      return TaskCategoryModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to create category: $e');
    }
  }

  @override
  Future<void> updateCategory(
    String id,
    String name,
    String color,
    String icon,
  ) async {
    try {
      await apiClient.put(
        ApiEndpoints.taskCategoryById(id),
        data: {'name': name, 'color': color, 'icon': icon},
      );
    } catch (e) {
      throw Exception('Failed to update category: $e');
    }
  }

  @override
  Future<void> deleteCategory(String id) async {
    try {
      await apiClient.delete(ApiEndpoints.taskCategoryById(id));
    } catch (e) {
      throw Exception('Failed to delete category: $e');
    }
  }

  // ========== Statistics ==========
  @override
  Future<TaskStatisticsModel> getTaskStatistics() async {
    try {
      final response = await apiClient.get(ApiEndpoints.taskStatistics);
      return TaskStatisticsModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to fetch task statistics: $e');
    }
  }
}
