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
      id: (json['task_id'] ?? json['id'] ?? '').toString(),
      title: json['title'] ?? '',
      description: json['description'],
      date: json['due_date'] != null 
          ? DateTime.parse(json['due_date']) 
          : (json['date'] != null ? DateTime.parse(json['date']) : DateTime.now()),
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : (json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now()),
      isDone: json['status'] == 'completed' || json['completed'] == true || json['is_done'] == true || json['isDone'] == true,
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
      relatedNoteId: (json['note_id'] ?? json['related_note_id'] ?? json['relatedNoteId'])?.toString(),
    );
  }

  // --- TO JSON ---
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'due_date': date.toIso8601String(),
      'priority': priority.name,
      'tags': tags.map((e) => e.name).toList(),
      'completed': isDone,
      'note_id': relatedNoteId,
    };
  }

  // Helper Methods
  static TaskPriority _parsePriority(String? p) {
    if (p == null) return TaskPriority.medium;
    final lowerP = p.toLowerCase();
    return TaskPriority.values.firstWhere(
      (e) => e.name.toLowerCase() == lowerP,
      orElse: () => TaskPriority.medium,
    );
  }

  static AppTag _parseTag(String t) {
    final lowerT = t.toLowerCase();
    return AppTag.values.firstWhere(
      (e) => e.name.toLowerCase() == lowerT || e.label.toLowerCase() == lowerT,
      orElse: () => AppTag.personal, // Default tag
    );
  }
}

class SubTaskModel extends SubTask {
  const SubTaskModel({required super.id, required super.title, super.isDone});

  factory SubTaskModel.fromJson(Map<String, dynamic> json) {
    return SubTaskModel(
      id: (json['subtask_id'] ?? json['id'] ?? '').toString(),
      title: json['title'] ?? '',
      isDone: json['status'] == 'completed' || json['completed'] == true || json['is_done'] == true || json['isDone'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {'title': title, 'completed': isDone};
  }
}
