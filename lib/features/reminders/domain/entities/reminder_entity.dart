import 'package:equatable/equatable.dart';

class ReminderEntity extends Equatable {
  final String id;
  final String taskId;
  final DateTime reminderTime;
  final String reminderType;
  final bool isActive;
  final DateTime createdAt;

  const ReminderEntity({
    required this.id,
    required this.taskId,
    required this.reminderTime,
    required this.reminderType,
    required this.isActive,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    taskId,
    reminderTime,
    reminderType,
    isActive,
    createdAt,
  ];
}
