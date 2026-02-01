import '../../domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required int id,
    required int userId,
    required String title,
    required String message,
    required String type,
    required String priority,
    required bool isRead,
    DateTime? readAt,
    int? relatedId,
    required DateTime createdAt,
  }) : super(
         id: id,
         userId: userId,
         title: title,
         message: message,
         type: type,
         priority: priority,
         isRead: isRead,
         readAt: readAt,
         relatedId: relatedId,
         createdAt: createdAt,
       );

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['notification_id'] as int,
      userId: json['user_id'] as int,
      title: json['title'] as String,
      message: json['message'] as String,
      type: json['type'] as String,
      priority: json['priority'] as String,
      isRead: json['is_read'] as bool,
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
      relatedId: json['related_id'] as int?,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notification_id': id,
      'user_id': userId,
      'title': title,
      'message': message,
      'type': type,
      'priority': priority,
      'is_read': isRead,
      'read_at': readAt?.toIso8601String(),
      'related_id': relatedId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  NotificationEntity toEntity() {
    return NotificationEntity(
      id: id,
      userId: userId,
      title: title,
      message: message,
      type: type,
      priority: priority,
      isRead: isRead,
      readAt: readAt,
      relatedId: relatedId,
      createdAt: createdAt,
    );
  }
}
