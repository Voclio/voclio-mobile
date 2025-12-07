import 'package:voclio_app/features/reminders/domain/entities/reminder_entity.dart';

class ReminderModel {
  final String id;
  final String taskId;
  final DateTime reminderTime;
  final String reminderType;
  final bool isActive;
  final DateTime createdAt;

  ReminderModel({
    required this.id,
    required this.taskId,
    required this.reminderTime,
    required this.reminderType,
    required this.isActive,
    required this.createdAt,
  });

  factory ReminderModel.fromJson(Map<String, dynamic> json) {
    return ReminderModel(
      id: json['reminder_id'] ?? json['id'] ?? '',
      taskId: json['task_id'] ?? '',
      reminderTime: DateTime.parse(json['reminder_time']),
      reminderType: json['reminder_type'] ?? 'one_time',
      isActive: json['is_active'] ?? true,
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'task_id': taskId,
      'reminder_time': reminderTime.toIso8601String(),
      'reminder_type': reminderType,
    };
  }

  ReminderEntity toEntity() {
    return ReminderEntity(
      id: id,
      taskId: taskId,
      reminderTime: reminderTime,
      reminderType: reminderType,
      isActive: isActive,
      createdAt: createdAt,
    );
  }

  factory ReminderModel.fromEntity(ReminderEntity entity) {
    return ReminderModel(
      id: entity.id,
      taskId: entity.taskId,
      reminderTime: entity.reminderTime,
      reminderType: entity.reminderType,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
    );
  }
}
