import 'package:voclio_app/core/api/api_client.dart';
import 'package:voclio_app/core/api/api_endpoints.dart';
import '../models/tag_model.dart';

abstract class TagRemoteDataSource {
  Future<List<TagModel>> getTags();
  Future<TagModel> getTag(String id);
  Future<TagModel> createTag(TagModel tag);
  Future<TagModel> updateTag(String id, TagModel tag);
  Future<void> deleteTag(String id);
}

class TagRemoteDataSourceImpl implements TagRemoteDataSource {
  final ApiClient apiClient;

  TagRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<TagModel>> getTags() async {
    try {
      final response = await apiClient.get(ApiEndpoints.tags);
      final List<dynamic> data = response.data['data'];
      return data.map((json) => TagModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch tags: $e');
    }
  }

  @override
  Future<TagModel> getTag(String id) async {
    try {
      final response = await apiClient.get(ApiEndpoints.tagById(id));
      return TagModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to fetch tag: $e');
    }
  }

  @override
  Future<TagModel> createTag(TagModel tag) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.tags,
        data: tag.toJson(),
      );
      return TagModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to create tag: $e');
    }
  }

  @override
  Future<TagModel> updateTag(String id, TagModel tag) async {
    try {
      final response = await apiClient.put(
        ApiEndpoints.tagById(id),
        data: tag.toJson(),
      );
      return TagModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to update tag: $e');
    }
  }

  @override
  Future<void> deleteTag(String id) async {
    try {
      await apiClient.delete(ApiEndpoints.tagById(id));
    } catch (e) {
      throw Exception('Failed to delete tag: $e');
    }
  }
}
