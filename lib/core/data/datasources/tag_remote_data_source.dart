import 'package:voclio_app/core/api/api_client.dart';
import 'package:voclio_app/core/api/api_endpoints.dart';
import 'package:voclio_app/core/data/models/tag_model.dart';

abstract class TagRemoteDataSource {
  Future<List<TagModel>> getTags();
}

class TagRemoteDataSourceImpl implements TagRemoteDataSource {
  final ApiClient apiClient;

  TagRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<TagModel>> getTags() async {
    try {
      final response = await apiClient.get(ApiEndpoints.tags);
      return _parseTagsResponse(response.data);
    } catch (e) {
      throw Exception('Failed to fetch tags: $e');
    }
  }

  List<TagModel> _parseTagsResponse(dynamic rawData) {
    List<dynamic>? tagsList;

    if (rawData is Map) {
      if (rawData['data'] != null) {
        final data = rawData['data'];
        if (data is Map && data['tags'] != null) {
          tagsList = data['tags'];
        } else if (data is List) {
          tagsList = data;
        }
      } else if (rawData['tags'] != null) {
        tagsList = rawData['tags'];
      }
    } else if (rawData is List) {
      tagsList = rawData;
    }

    tagsList ??= [];

    // Filter out tags as requested: "work", "اتجاهات", "وشروق الشمس"
    final tagsToHide = {'work', 'اتجاهات', 'وشروق الشمس', 'شروق الشمس'};

    return tagsList
        .map((json) => TagModel.fromJson(json))
        .where((tag) => !tagsToHide.contains(tag.name))
        .toList();
  }
}
