import 'package:voclio_app/core/api/api_client.dart';
import 'package:voclio_app/core/api/api_endpoints.dart';
import '../models/user_settings_model.dart';

abstract class SettingsRemoteDataSource {
  Future<UserSettingsModel> getSettings();
  Future<UserSettingsModel> updateSettings(Map<String, dynamic> data);
  Future<UserSettingsModel> updateTheme(String theme);
  Future<UserSettingsModel> updateLanguage(String language);
  Future<UserSettingsModel> updateTimezone(String timezone);
  Future<Map<String, dynamic>> getNotificationSettings();
  Future<UserSettingsModel> updateNotifications(Map<String, dynamic> data);
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

  @override
  Future<UserSettingsModel> updateTheme(String theme) async {
    try {
      final response = await apiClient.put(
        ApiEndpoints.settingsTheme,
        data: {'theme': theme},
      );
      return UserSettingsModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to update theme: $e');
    }
  }

  @override
  Future<UserSettingsModel> updateLanguage(String language) async {
    try {
      final response = await apiClient.put(
        ApiEndpoints.settingsLanguage,
        data: {'language': language},
      );
      return UserSettingsModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to update language: $e');
    }
  }

  @override
  Future<UserSettingsModel> updateTimezone(String timezone) async {
    try {
      final response = await apiClient.put(
        ApiEndpoints.settingsTimezone,
        data: {'timezone': timezone},
      );
      return UserSettingsModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to update timezone: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getNotificationSettings() async {
    try {
      final response = await apiClient.get(ApiEndpoints.settingsNotifications);
      return response.data['data'] ?? response.data;
    } catch (e) {
      throw Exception('Failed to fetch notification settings: $e');
    }
  }

  @override
  Future<UserSettingsModel> updateNotifications(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await apiClient.put(
        ApiEndpoints.settingsNotifications,
        data: data,
      );
      return UserSettingsModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to update notifications: $e');
    }
  }
}
