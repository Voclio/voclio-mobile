import 'package:voclio_app/core/enums/enums.dart';
import 'package:voclio_app/features/tasks/domain/entities/task_entity.dart';

class TaskModel extends TaskEntity {
  const TaskModel({
    required super.id,
    required super.title,
    required super.date,
    required super.createdAt,
    super.description,
    super.isDone,
    super.priority,
    super.subtasks,
    super.tags,
    super.relatedNoteId,
  });

  // --- FROM JSON ---
  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      date: DateTime.parse(json['date']),
      createdAt: DateTime.parse(json['createdAt']),
      isDone: json['isDone'] ?? false,
      priority: _parsePriority(json['priority']),
      tags:
          (json['tags'] as List<dynamic>?)
              ?.map((e) => _parseTag(e.toString()))
              .toList() ??
          [],
      subtasks:
          (json['subtasks'] as List<dynamic>?)
              ?.map((e) => SubTaskModel.fromJson(e))
              .toList() ??
          [],
      relatedNoteId: json['relatedNoteId'] as String?,
    );
  }

  // --- TO JSON ---
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'isDone': isDone,
      'priority': priority.name,
      'tags': tags.map((e) => e.name).toList(),
      'subtasks': subtasks.map((e) => (e as SubTaskModel).toJson()).toList(),
      'relatedNoteId': relatedNoteId,
    };
  }

  // Helper Methods
  static TaskPriority _parsePriority(String? p) {
    return TaskPriority.values.firstWhere(
      (e) => e.name == p,
      orElse: () => TaskPriority.medium,
    );
  }

  static AppTag _parseTag(String t) {
    return AppTag.values.firstWhere(
      (e) => e.name == t,
      orElse: () => AppTag.personal, // Default tag
    );
  }
}

class SubTaskModel extends SubTask {
  const SubTaskModel({required super.id, required super.title, super.isDone});

  factory SubTaskModel.fromJson(Map<String, dynamic> json) {
    return SubTaskModel(
      id: json['id'],
      title: json['title'],
      isDone: json['isDone'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'title': title, 'isDone': isDone};
  }
}
