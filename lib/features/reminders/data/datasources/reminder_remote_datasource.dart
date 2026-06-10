import 'package:flutter/foundation.dart';
import 'package:voclio_app/core/api/api_client.dart';
import 'package:voclio_app/core/api/api_endpoints.dart';
import 'package:voclio_app/core/api/api_response.dart';
import '../models/reminder_model.dart';

abstract class ReminderRemoteDataSource {
  Future<List<ReminderModel>> getReminders();
  Future<List<ReminderModel>> getUpcomingReminders();
  Future<ReminderModel> getReminder(String id);
  Future<ReminderModel> createReminder(ReminderModel reminder);
  Future<ReminderModel> updateReminder(String id, ReminderModel reminder);
  Future<void> snoozeReminder(String id, int minutes);
  Future<void> dismissReminder(String id);
  Future<void> deleteReminder(String id);
}

class ReminderRemoteDataSourceImpl implements ReminderRemoteDataSource {
  final ApiClient apiClient;

  ReminderRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<ReminderModel>> getReminders() async {
    debugPrint('📌 GET Reminders - calling API: ${ApiEndpoints.reminders}');
    final response = await apiClient.get(ApiEndpoints.reminders);
    debugPrint('📌 GET Reminders - response: ${response.data}');
    final list = ApiResponse.unwrapList(response.data);
    debugPrint('📌 GET Reminders - parsed ${list.length} items');
    return list
        .map((json) => ReminderModel.fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }

  @override
  Future<List<ReminderModel>> getUpcomingReminders() async {
    final response = await apiClient.get(ApiEndpoints.upcomingReminders);
    final list = ApiResponse.unwrapList(response.data, key: 'reminders');
    return list
        .map((json) => ReminderModel.fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }

  @override
  Future<ReminderModel> getReminder(String id) async {
    final response = await apiClient.get(ApiEndpoints.reminderById(id));
    final data = ApiResponse.unwrapMap(response.data);
    final reminder = data['reminder'] ?? data;
    return ReminderModel.fromJson(Map<String, dynamic>.from(reminder));
  }

  @override
  Future<ReminderModel> createReminder(ReminderModel reminder) async {
    debugPrint('📌 CREATE Reminder - calling API: ${ApiEndpoints.reminders}');
    debugPrint('📌 CREATE Reminder - data: ${reminder.toJson()}');
    final response = await apiClient.post(
      ApiEndpoints.reminders,
      data: reminder.toJson(),
    );
    debugPrint('📌 CREATE Reminder - response: ${response.data}');
    final data = ApiResponse.unwrapMap(response.data);
    final created = data['reminder'] ?? data;
    return ReminderModel.fromJson(Map<String, dynamic>.from(created));
  }

  @override
  Future<ReminderModel> updateReminder(
    String id,
    ReminderModel reminder,
  ) async {
    final response = await apiClient.put(
      ApiEndpoints.reminderById(id),
      data: reminder.toJson(),
    );
    final data = ApiResponse.unwrapMap(response.data);
    final updated = data['reminder'] ?? data;
    return ReminderModel.fromJson(Map<String, dynamic>.from(updated));
  }

  @override
  Future<void> snoozeReminder(String id, int minutes) async {
    await apiClient.put(
      ApiEndpoints.snoozeReminder(id),
      data: {'snooze_minutes': minutes},
    );
  }

  @override
  Future<void> dismissReminder(String id) async {
    await apiClient.put(ApiEndpoints.dismissReminder(id));
  }

  @override
  Future<void> deleteReminder(String id) async {
    await apiClient.delete(ApiEndpoints.reminderById(id));
  }
}
