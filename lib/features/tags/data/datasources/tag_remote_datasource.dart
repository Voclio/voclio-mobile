import 'package:voclio_app/core/api/api_client.dart';
import 'package:voclio_app/core/api/api_endpoints.dart';
import '../models/tag_model.dart';

abstract class TagRemoteDataSource {
  Future<List<TagModel>> getTags();
  Future<TagModel> createTag(String name, String color);
  Future<TagModel> updateTag(String id, String name, String color);
  Future<void> deleteTag(String id);
}

class TagRemoteDataSourceImpl implements TagRemoteDataSource {
  final ApiClient apiClient;

  TagRemoteDataSourceImpl({required this.apiClient});

  // Mock data storage
  static final List<TagModel> _mockTags = [
    TagModel(
      id: '1',
      name: 'Work',
      color: '#2196F3',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    TagModel(
      id: '2',
      name: 'Personal',
      color: '#4CAF50',
      createdAt: DateTime.now().subtract(const Duration(days: 8)),
    ),
    TagModel(
      id: '3',
      name: 'Urgent',
      color: '#F44336',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    TagModel(
      id: '4',
      name: 'Study',
      color: '#9C27B0',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    TagModel(
      id: '5',
      name: 'Health',
      color: '#FF9800',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  @override
  Future<List<TagModel>> getTags() async {
    try {
      final response = await apiClient.get(ApiEndpoints.tags);
      final List<dynamic> data = response.data['data'];
      return data.map((json) => TagModel.fromJson(json)).toList();
    } catch (e) {
      // Return mock data
      return List.from(_mockTags);
    }
  }

  @override
  Future<TagModel> createTag(String name, String color) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.tags,
        data: {'name': name, 'color': color},
      );
      return TagModel.fromJson(response.data['data']);
    } catch (e) {
      // Mock: Create new tag
      final newTag = TagModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        color: color,
        createdAt: DateTime.now(),
      );
      _mockTags.add(newTag);
      return newTag;
    }
  }

  @override
  Future<TagModel> updateTag(String id, String name, String color) async {
    try {
      final response = await apiClient.put(
        ApiEndpoints.tagById(id),
        data: {'name': name, 'color': color},
      );
      return TagModel.fromJson(response.data['data']);
    } catch (e) {
      // Mock: Update tag
      final index = _mockTags.indexWhere((t) => t.id == id);
      if (index != -1) {
        final updatedTag = TagModel(
          id: id,
          name: name,
          color: color,
          createdAt: _mockTags[index].createdAt,
        );
        _mockTags[index] = updatedTag;
        return updatedTag;
      }
      throw Exception('Tag not found');
    }
  }

  @override
  Future<void> deleteTag(String id) async {
    try {
      await apiClient.delete(ApiEndpoints.tagById(id));
    } catch (e) {
      // Mock: Remove tag
      _mockTags.removeWhere((t) => t.id == id);
      return;
    }
  }
}
