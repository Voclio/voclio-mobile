import 'package:voclio_app/core/api/api_client.dart';
import 'package:voclio_app/core/api/api_endpoints.dart';
import '../models/category_model.dart';

abstract class CategoryRemoteDataSource {
  Future<List<CategoryModel>> getCategories();
  Future<CategoryModel> getCategoryById(String id);
  Future<CategoryStatsModel> getCategoryStats(String id);
  Future<CategoryModel> createCategory(CategoryModel category);
  Future<CategoryModel> updateCategory(String id, CategoryModel category);
  Future<void> deleteCategory(String id);
}

class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  final ApiClient apiClient;

  CategoryRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await apiClient.get(ApiEndpoints.categories);
      final rawData = response.data;
      List<dynamic> dataList = [];

      if (rawData is Map &&
          rawData['data'] is Map &&
          rawData['data']['categories'] is List) {
        dataList = rawData['data']['categories'];
      } else if (rawData is Map && rawData['data'] is List) {
        dataList = rawData['data'];
      } else if (rawData is List) {
        dataList = rawData;
      }

      return dataList.map((json) => CategoryModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }

  @override
  Future<CategoryModel> getCategoryById(String id) async {
    try {
      final response = await apiClient.get(ApiEndpoints.categoryById(id));
      final rawData = response.data;

      if (rawData is Map &&
          rawData['data'] is Map &&
          rawData['data']['category'] != null) {
        return CategoryModel.fromJson(rawData['data']['category']);
      } else if (rawData is Map && rawData['data'] != null) {
        return CategoryModel.fromJson(rawData['data']);
      }
      return CategoryModel.fromJson(rawData);
    } catch (e) {
      throw Exception('Failed to fetch category: $e');
    }
  }

  @override
  Future<CategoryStatsModel> getCategoryStats(String id) async {
    try {
      final response = await apiClient.get(ApiEndpoints.categoryStats(id));
      final rawData = response.data;

      if (rawData is Map && rawData['data'] != null) {
        return CategoryStatsModel.fromJson(rawData['data']);
      }
      return CategoryStatsModel.fromJson(rawData);
    } catch (e) {
      throw Exception('Failed to fetch category stats: $e');
    }
  }

  @override
  Future<CategoryModel> createCategory(CategoryModel category) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.categories,
        data: category.toJson(),
      );
      final rawData = response.data;

      if (rawData is Map &&
          rawData['data'] is Map &&
          rawData['data']['category'] != null) {
        return CategoryModel.fromJson(rawData['data']['category']);
      } else if (rawData is Map && rawData['data'] != null) {
        return CategoryModel.fromJson(rawData['data']);
      }
      return CategoryModel.fromJson(rawData);
    } catch (e) {
      throw Exception('Failed to create category: $e');
    }
  }

  @override
  Future<CategoryModel> updateCategory(
    String id,
    CategoryModel category,
  ) async {
    try {
      final response = await apiClient.put(
        ApiEndpoints.categoryById(id),
        data: category.toJson(),
      );
      final rawData = response.data;

      if (rawData is Map &&
          rawData['data'] is Map &&
          rawData['data']['category'] != null) {
        return CategoryModel.fromJson(rawData['data']['category']);
      } else if (rawData is Map && rawData['data'] != null) {
        return CategoryModel.fromJson(rawData['data']);
      }
      return CategoryModel.fromJson(rawData);
    } catch (e) {
      throw Exception('Failed to update category: $e');
    }
  }

  @override
  Future<void> deleteCategory(String id) async {
    try {
      await apiClient.delete(ApiEndpoints.categoryById(id));
    } catch (e) {
      throw Exception('Failed to delete category: $e');
    }
  }
}
