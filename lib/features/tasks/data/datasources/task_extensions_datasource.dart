import 'package:voclio_app/core/api/api_client.dart';
import 'package:voclio_app/core/api/api_endpoints.dart';
import '../models/task_extensions_models.dart';

abstract class TaskExtensionsDataSource {
  Future<List<SubtaskModel>> getSubtasks(String taskId);
  Future<SubtaskModel> createSubtask(String taskId, String title, int order);
  Future<void> updateSubtask(String subtaskId, String title, bool completed);
  Future<void> deleteSubtask(String subtaskId);

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
        ApiEndpoints.subtasks(taskId),
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
