import 'package:voclio_app/core/api/api_client.dart';
import 'package:voclio_app/core/api/api_endpoints.dart';
import 'package:voclio_app/core/api/api_response.dart';
import '../models/task_extensions_models.dart';

abstract class TaskExtensionsDataSource {
  Future<List<SubtaskModel>> getSubtasks(String taskId);
  Future<SubtaskModel> createSubtask(String taskId, String title, int order);
  Future<void> updateSubtask(
    String taskId,
    String subtaskId,
    String title,
    bool completed,
  );
  Future<void> deleteSubtask(String taskId, String subtaskId);

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

  Future<TaskStatisticsModel> getTaskStatistics();
}

class TaskExtensionsDataSourceImpl implements TaskExtensionsDataSource {
  final ApiClient apiClient;

  TaskExtensionsDataSourceImpl({required this.apiClient});

  @override
  Future<List<SubtaskModel>> getSubtasks(String taskId) async {
    try {
      final response = await apiClient.get(ApiEndpoints.subtasks(taskId));
      final list = ApiResponse.unwrapList(response.data, key: 'subtasks');
      return list
          .map((json) => SubtaskModel.fromJson(Map<String, dynamic>.from(json)))
          .toList();
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
        ApiEndpoints.subtasks(taskId),
        data: {'title': title, 'order': order},
      );
      final data = ApiResponse.unwrapMap(response.data);
      final subtask = data['subtask'] ?? data;
      return SubtaskModel.fromJson(Map<String, dynamic>.from(subtask as Map));
    } catch (e) {
      throw Exception('Failed to create subtask: $e');
    }
  }

  @override
  Future<void> updateSubtask(
    String taskId,
    String subtaskId,
    String title,
    bool completed,
  ) async {
    try {
      await apiClient.put(
        ApiEndpoints.subtaskById(taskId, subtaskId),
        data: {
          'title': title,
          'status': completed ? 'completed' : 'pending',
        },
      );
    } catch (e) {
      throw Exception('Failed to update subtask: $e');
    }
  }

  @override
  Future<void> deleteSubtask(String taskId, String subtaskId) async {
    try {
      await apiClient.delete(ApiEndpoints.subtaskById(taskId, subtaskId));
    } catch (e) {
      throw Exception('Failed to delete subtask: $e');
    }
  }

  @override
  Future<List<TaskCategoryModel>> getCategories() async {
    try {
      final response = await apiClient.get(ApiEndpoints.taskCategories);
      final list = ApiResponse.unwrapList(response.data, key: 'categories');
      return list
          .map((json) => TaskCategoryModel.fromJson(Map<String, dynamic>.from(json)))
          .toList();
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
      final data = ApiResponse.unwrapMap(response.data);
      final category = data['category'] ?? data;
      return TaskCategoryModel.fromJson(Map<String, dynamic>.from(category as Map));
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

  @override
  Future<TaskStatisticsModel> getTaskStatistics() async {
    try {
      final response = await apiClient.get(ApiEndpoints.taskStatistics);
      final data = ApiResponse.unwrapMap(response.data);
      final stats = data['stats'] ?? data;
      return TaskStatisticsModel.fromJson(Map<String, dynamic>.from(stats as Map));
    } catch (e) {
      throw Exception('Failed to fetch task statistics: $e');
    }
  }
}
