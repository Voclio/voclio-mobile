import 'package:equatable/equatable.dart';

class ReminderEntity extends Equatable {
  final String id;
  final String title;
  final String? description;
  final DateTime remindAt;
  final int? taskId;
  final String reminderType;
  final bool isActive;
  final DateTime createdAt;

  const ReminderEntity({
    required this.id,
    required this.title,
    this.description,
    required this.remindAt,
    this.taskId,
    required this.reminderType,
    required this.isActive,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    remindAt,
    taskId,
    reminderType,
    isActive,
    createdAt,
  ];
}
