import 'package:voclio_app/core/api/api_client.dart';
import 'package:voclio_app/core/api/api_endpoints.dart';
import '../models/notification_model.dart';

abstract class NotificationRemoteDataSource {
  Future<List<NotificationModel>> getNotifications();
  Future<int> getUnreadCount();
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead();
  Future<void> deleteNotification(String id);
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final ApiClient apiClient;

  NotificationRemoteDataSourceImpl({required this.apiClient});

  // Mock data storage
  static final List<NotificationModel> _mockNotifications = [
    NotificationModel(
      id: '1',
      title: 'Task Reminder',
      message: 'You have a task due in 1 hour',
      type: 'reminder',
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
    NotificationModel(
      id: '2',
      title: 'Achievement Unlocked',
      message: 'You completed your first focus session!',
      type: 'achievement',
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    NotificationModel(
      id: '3',
      title: 'Daily Summary',
      message: 'You completed 5 tasks today. Great work!',
      type: 'info',
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    NotificationModel(
      id: '4',
      title: 'Streak Milestone',
      message: 'You reached a 7-day streak!',
      type: 'achievement',
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  @override
  Future<List<NotificationModel>> getNotifications() async {
    try {
      final response = await apiClient.get(ApiEndpoints.notifications);
      final List<dynamic> data = response.data['data'];
      return data.map((json) => NotificationModel.fromJson(json)).toList();
    } catch (e) {
      // Return mock data
      return List.from(_mockNotifications);
    }
  }

  @override
  Future<int> getUnreadCount() async {
    try {
      final response = await apiClient.get(ApiEndpoints.unreadCount);
      return response.data['data']['count'] ?? 0;
    } catch (e) {
      // Return mock unread count from current notifications
      return _mockNotifications.where((n) => !n.isRead).length;
    }
  }

  @override
  Future<void> markAsRead(String id) async {
    try {
      await apiClient.put(ApiEndpoints.notificationById(id));
    } catch (e) {
      // Mock: Mark notification as read
      final index = _mockNotifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        final notification = _mockNotifications[index];
        _mockNotifications[index] = NotificationModel(
          id: notification.id,
          title: notification.title,
          message: notification.message,
          type: notification.type,
          isRead: true,
          createdAt: notification.createdAt,
        );
      }
      return;
    }
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      await apiClient.put(ApiEndpoints.markAllRead);
    } catch (e) {
      // Mock: Mark all as read
      for (int i = 0; i < _mockNotifications.length; i++) {
        final notification = _mockNotifications[i];
        _mockNotifications[i] = NotificationModel(
          id: notification.id,
          title: notification.title,
          message: notification.message,
          type: notification.type,
          isRead: true,
          createdAt: notification.createdAt,
        );
      }
      return;
    }
  }

  @override
  Future<void> deleteNotification(String id) async {
    try {
      await apiClient.delete(ApiEndpoints.notificationById(id));
    } catch (e) {
      // Mock: Remove notification
      _mockNotifications.removeWhere((n) => n.id == id);
      return;
    }
  }
}
