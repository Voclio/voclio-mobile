import 'package:flutter/foundation.dart';
import 'package:voclio_app/core/api/api_client.dart';
import 'package:voclio_app/core/api/api_endpoints.dart';
import '../models/task_model.dart';
import '../models/task_extensions_models.dart';

abstract class TaskRemoteDataSource {
  Future<List<TaskModel>> getTasks();
  Future<List<TaskModel>> getTasksByCategory(String categoryId);
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
  final ApiClient apiClient;

  TaskRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<TaskModel>> getTasks() async {
    try {
      final response = await apiClient.get(ApiEndpoints.tasks);
      return _parseTasksResponse(response.data);
    } catch (e) {
      throw Exception('Failed to fetch tasks: $e');
    }
  }

  @override
  Future<List<TaskModel>> getTasksByCategory(String categoryId) async {
    try {
      // Endpoint: {{baseUrl}}/tasks/by-category?category_id={{categoryId}}
      final response = await apiClient.get(
        ApiEndpoints.tasksByCategory,
        queryParameters: {'category_id': categoryId},
      );
      return _parseTasksResponse(response.data);
    } catch (e) {
      throw Exception('Failed to fetch tasks by category: $e');
    }
  }

  List<TaskModel> _parseTasksResponse(dynamic rawData) {
    // Debug log to see what the server is actually returning
    debugPrint('DEBUG: Tasks raw data: $rawData');

    // Try multiple possible paths for the tasks list
    List<dynamic>? tasksList;

    if (rawData is Map) {
      if (rawData['data'] != null) {
        final dataMap = rawData['data'];
        if (dataMap is Map) {
          tasksList = dataMap['tasks'] ?? dataMap['data'] ?? dataMap['items'];
        } else if (dataMap is List) {
          tasksList = dataMap;
        }
      } else if (rawData['tasks'] != null) {
        tasksList = rawData['tasks'];
      } else if (rawData['items'] != null) {
        tasksList = rawData['items'];
      }
    } else if (rawData is List) {
      tasksList = rawData;
    }

    tasksList ??= [];

    return tasksList.map((e) => TaskModel.fromRawData(e)).toList();
  }

  @override
  Future<TaskModel> addTask(TaskModel task) async {
    final response = await apiClient.post(
      ApiEndpoints.tasks,
      data: task.toJson(),
    );
    return TaskModel.fromRawData(response.data);
  }

  @override
  Future<TaskModel> updateTask(TaskModel task) async {
    try {
      final response = await apiClient.put(
        ApiEndpoints.taskById(task.id),
        data: task.toJson(),
      );
      return TaskModel.fromRawData(response.data);
    } catch (e) {
      // If update fails, we might still want to return the original task
      // or rethrow. For now, we rethrow for the UI to handle.
      rethrow;
    }
  }

  @override
  Future<void> deleteTask(String id) async {
    await apiClient.delete(ApiEndpoints.taskById(id));
  }

  @override
  Future<TaskModel?> getTask(String taskId) async {
    try {
      final response = await apiClient.get(ApiEndpoints.taskById(taskId));
      return TaskModel.fromRawData(response.data);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> completeTask(String id) async {
    try {
      await apiClient.put(
        ApiEndpoints.completeTask(id),
        data: {'status': 'completed'},
      );
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
      return _parseCategoriesResponse(response.data);
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }

  List<TaskCategoryModel> _parseCategoriesResponse(dynamic rawData) {
    List<dynamic>? list;

    if (rawData is Map) {
      if (rawData['data'] != null) {
        final data = rawData['data'];
        if (data is List) {
          list = data;
        } else if (data is Map && data['categories'] != null) {
          list = data['categories'];
        }
      } else if (rawData['categories'] != null) {
        list = rawData['categories'];
      }
    } else if (rawData is List) {
      list = rawData;
    }

    list ??= [];
    return list.map((json) => TaskCategoryModel.fromJson(json)).toList();
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
