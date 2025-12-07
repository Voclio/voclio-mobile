import 'package:voclio_app/core/api/api_client.dart';
import 'package:voclio_app/core/api/api_endpoints.dart';
import '../models/user_settings_model.dart';

abstract class SettingsRemoteDataSource {
  Future<UserSettingsModel> getSettings();
  Future<UserSettingsModel> updateSettings(Map<String, dynamic> data);
}

class SettingsRemoteDataSourceImpl implements SettingsRemoteDataSource {
  final ApiClient apiClient;

  SettingsRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<UserSettingsModel> getSettings() async {
    try {
      final response = await apiClient.get(ApiEndpoints.settings);
      return UserSettingsModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to fetch settings: $e');
    }
  }

  @override
  Future<UserSettingsModel> updateSettings(Map<String, dynamic> data) async {
    try {
      final response = await apiClient.put(ApiEndpoints.settings, data: data);
      return UserSettingsModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to update settings: $e');
    }
  }
}
