import 'package:voclio_app/features/reminders/domain/entities/reminder_entity.dart';

class ReminderModel {
  final String id;
  final String title;
  final String? description;
  final DateTime remindAt;
  final int? taskId;
  final String reminderType;
  final bool isActive;
  final DateTime createdAt;

  ReminderModel({
    required this.id,
    required this.title,
    this.description,
    required this.remindAt,
    this.taskId,
    required this.reminderType,
    required this.isActive,
    required this.createdAt,
  });

  factory ReminderModel.fromJson(Map<String, dynamic> json) {
    return ReminderModel(
      id: (json['reminder_id'] ?? json['id'] ?? '').toString(),
      title: json['title'] ?? '',
      description: json['description'],
      remindAt: DateTime.parse(json['remind_at']),
      taskId: json['task_id'],
      reminderType: json['reminder_type'] ?? 'one_time',
      isActive: json['is_active'] ?? true,
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    if (taskId == null) {
      throw ArgumentError('task_id is required to create a reminder');
    }
    final json = <String, dynamic>{
      'title': title,
      'remind_at': remindAt.toUtc().toIso8601String(),
      'task_id': taskId,
    };
    if (description != null && description!.isNotEmpty) {
      json['description'] = description;
    }
    return json;
  }

  ReminderEntity toEntity() {
    return ReminderEntity(
      id: id,
      title: title,
      description: description,
      remindAt: remindAt,
      taskId: taskId,
      reminderType: reminderType,
      isActive: isActive,
      createdAt: createdAt,
    );
  }

  factory ReminderModel.fromEntity(ReminderEntity entity) {
    return ReminderModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      remindAt: entity.remindAt,
      taskId: entity.taskId,
      reminderType: entity.reminderType,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
    );
  }
}
