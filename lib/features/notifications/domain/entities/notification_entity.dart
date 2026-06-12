import 'package:equatable/equatable.dart';

class NotificationEntity extends Equatable {
  final int id;
  final int userId;
  final String title;
  final String message;
  final String type;
  final String priority;
  final bool isRead;
  final DateTime? readAt;
  final int? relatedId;
  final DateTime createdAt;

  const NotificationEntity({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    required this.priority,
    required this.isRead,
    this.readAt,
    this.relatedId,
    required this.createdAt,
  });

  NotificationEntity copyWith({
    int? id,
    int? userId,
    String? title,
    String? message,
    String? type,
    String? priority,
    bool? isRead,
    DateTime? readAt,
    int? relatedId,
    DateTime? createdAt,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      relatedId: relatedId ?? this.relatedId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    title,
    message,
    type,
    priority,
    isRead,
    readAt,
    relatedId,
    createdAt,
  ];
}
