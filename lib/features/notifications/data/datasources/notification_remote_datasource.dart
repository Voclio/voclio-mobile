import 'package:voclio_app/core/api/api_client.dart';
import 'package:voclio_app/core/api/api_endpoints.dart';
import '../models/notification_model.dart';
import '../models/notification_response_model.dart';

abstract class NotificationRemoteDataSource {
  Future<List<NotificationModel>> getNotifications();
  Future<int> getUnreadCount();
  Future<void> markAsRead(int id);
  Future<void> markAllAsRead();
  Future<void> deleteNotification(int id);
  Future<void> deleteAllNotifications();
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final ApiClient apiClient;

  NotificationRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<NotificationModel>> getNotifications() async {
    final response = await apiClient.get(ApiEndpoints.notifications);
    final responseModel = NotificationResponseModel.fromJson(response.data);
    return responseModel.data;
  }

  @override
  Future<int> getUnreadCount() async {
    final response = await apiClient.get(ApiEndpoints.unreadCount);
    return (response.data['data']['count'] ?? 0) as int;
  }

  @override
  Future<void> markAsRead(int id) async {
    await apiClient.put(ApiEndpoints.markNotificationRead(id.toString()));
  }

  @override
  Future<void> markAllAsRead() async {
    await apiClient.put(ApiEndpoints.markAllRead);
  }

  @override
  Future<void> deleteNotification(int id) async {
    await apiClient.delete(ApiEndpoints.notificationById(id.toString()));
  }

  @override
  Future<void> deleteAllNotifications() async {
    await apiClient.delete(ApiEndpoints.notifications);
  }
}
