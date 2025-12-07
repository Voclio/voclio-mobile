import 'package:voclio_app/core/api/api_client.dart';
import 'package:voclio_app/core/api/api_endpoints.dart';
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

  // Mock data storage
  static final List<ReminderModel> _mockReminders = [
    ReminderModel(
      id: '1',
      taskId: 'task1',
      reminderTime: DateTime.now().add(const Duration(hours: 2)),
      reminderType: 'one_time',
      isActive: true,
      createdAt: DateTime.now(),
    ),
    ReminderModel(
      id: '2',
      taskId: 'task2',
      reminderTime: DateTime.now().add(const Duration(days: 1)),
      reminderType: 'daily',
      isActive: true,
      createdAt: DateTime.now(),
    ),
    ReminderModel(
      id: '3',
      taskId: 'task3',
      reminderTime: DateTime.now().add(const Duration(days: 7)),
      reminderType: 'weekly',
      isActive: true,
      createdAt: DateTime.now(),
    ),
  ];

  @override
  Future<List<ReminderModel>> getReminders() async {
    try {
      final response = await apiClient.get(ApiEndpoints.reminders);
      final List<dynamic> data = response.data['data'];
      return data.map((json) => ReminderModel.fromJson(json)).toList();
    } catch (e) {
      // Return mock data if API fails
      return List.from(_mockReminders);
    }
  }

  @override
  Future<List<ReminderModel>> getUpcomingReminders() async {
    try {
      final response = await apiClient.get(ApiEndpoints.upcomingReminders);
      final List<dynamic> data = response.data['data'];
      return data.map((json) => ReminderModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch upcoming reminders: $e');
    }
  }

  @override
  Future<ReminderModel> getReminder(String id) async {
    try {
      final response = await apiClient.get(ApiEndpoints.reminderById(id));
      return ReminderModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to fetch reminder: $e');
    }
  }

  @override
  Future<ReminderModel> createReminder(ReminderModel reminder) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.reminders,
        data: reminder.toJson(),
      );
      return ReminderModel.fromJson(response.data['data']);
    } catch (e) {
      // Mock: Add new reminder
      final newReminder = ReminderModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        taskId: reminder.taskId,
        reminderTime: reminder.reminderTime,
        reminderType: reminder.reminderType,
        isActive: true,
        createdAt: DateTime.now(),
      );
      _mockReminders.add(newReminder);
      return newReminder;
    }
  }

  @override
  Future<ReminderModel> updateReminder(
    String id,
    ReminderModel reminder,
  ) async {
    try {
      final response = await apiClient.put(
        ApiEndpoints.reminderById(id),
        data: reminder.toJson(),
      );
      return ReminderModel.fromJson(response.data['data']);
    } catch (e) {
      // Mock: Update reminder
      final index = _mockReminders.indexWhere((r) => r.id == id);
      if (index != -1) {
        _mockReminders[index] = reminder;
        return reminder;
      }
      throw Exception('Reminder not found');
    }
  }

  @override
  Future<void> snoozeReminder(String id, int minutes) async {
    try {
      await apiClient.put(
        ApiEndpoints.snoozeReminder(id),
        data: {'snooze_minutes': minutes},
      );
    } catch (e) {
      // Mock: Update the reminder time
      final index = _mockReminders.indexWhere((r) => r.id == id);
      if (index != -1) {
        final reminder = _mockReminders[index];
        _mockReminders[index] = ReminderModel(
          id: reminder.id,
          taskId: reminder.taskId,
          reminderTime: DateTime.now().add(Duration(minutes: minutes)),
          reminderType: reminder.reminderType,
          isActive: reminder.isActive,
          createdAt: reminder.createdAt,
        );
      }
      return;
    }
  }

  @override
  Future<void> dismissReminder(String id) async {
    try {
      await apiClient.put(ApiEndpoints.dismissReminder(id));
    } catch (e) {
      // Mock: Remove the reminder
      _mockReminders.removeWhere((r) => r.id == id);
      return;
    }
  }

  @override
  Future<void> deleteReminder(String id) async {
    try {
      await apiClient.delete(ApiEndpoints.reminderById(id));
    } catch (e) {
      // Mock: Remove the reminder
      _mockReminders.removeWhere((r) => r.id == id);
      return;
    }
  }
}
