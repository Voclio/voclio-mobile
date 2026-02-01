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
