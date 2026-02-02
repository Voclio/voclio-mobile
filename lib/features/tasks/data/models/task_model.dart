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
  factory TaskModel.fromRawData(dynamic rawData) {
    if (rawData is! Map) {
      throw FormatException('Invalid raw data format for TaskModel: $rawData');
    }

    final Map<String, dynamic> map = Map<String, dynamic>.from(rawData);

    // 1. Check for double nesting: { "data": { "task": { ... } } }
    if (map['data'] is Map) {
      final dataMap = Map<String, dynamic>.from(map['data']);
      if (dataMap['task'] is Map) {
        return TaskModel.fromJson(Map<String, dynamic>.from(dataMap['task']));
      }
      if (dataMap['data'] is Map) {
        return TaskModel.fromJson(Map<String, dynamic>.from(dataMap['data']));
      }
      // If it's just { "data": { ...task fields... } }
      return TaskModel.fromJson(dataMap);
    }

    // 2. Check for single nesting: { "task": { ... } } or { "item": { ... } }
    final nested = map['task'] ?? map['item'] ?? map['data'];
    if (nested is Map) {
      return TaskModel.fromJson(Map<String, dynamic>.from(nested));
    }

    // 3. Root level
    return TaskModel.fromJson(map);
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: (json['task_id'] ?? json['id'] ?? '').toString(),
      title:
          json['title'] ??
          json['task_title'] ??
          json['task_name'] ??
          json['name'] ??
          json['text'] ??
          json['content'] ??
          json['label'] ??
          json['task'] ??
          '',
      description: json['description'] ?? json['desc'] ?? json['body'],
      date:
          json['due_date'] != null
              ? DateTime.parse(json['due_date'])
              : (json['date'] != null
                  ? DateTime.parse(json['date'])
                  : DateTime.now()),
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : (json['createdAt'] != null
                  ? DateTime.parse(json['createdAt'])
                  : DateTime.now()),
      isDone:
          json['status'] == 'completed' ||
          json['completed'] == true ||
          json['is_done'] == true ||
          json['isDone'] == true,
      priority: _parsePriority(json['priority']),
      tags: _parseTags(json),
      subtasks:
          (json['subtasks'] as List<dynamic>?)
              ?.map((e) => SubTaskModel.fromJson(e))
              .toList() ??
          [],
      relatedNoteId:
          (json['note_id'] ?? json['related_note_id'] ?? json['relatedNoteId'])
              ?.toString(),
    );
  }

  // --- TO JSON ---
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'title': title,
      'status': isDone ? 'completed' : 'todo',
      'priority': priority.name.toLowerCase(),
      'due_date': date.toIso8601String().split('.').first, // Clean ISO format
    };

    if (description != null && description!.isNotEmpty) {
      data['description'] = description;
    }

    if (relatedNoteId != null && relatedNoteId!.isNotEmpty) {
      data['note_id'] = relatedNoteId;
    }

    // Send tags under multiple keys for maximum compatibility
    if (tags.isNotEmpty) {
      data['tags'] = tags;
      data['tag_names'] = tags;
    }

    return data;
  }

  // Helper Methods
  static List<String> _parseTags(Map<String, dynamic> json) {
    var rawTags =
        json['tags'] ??
        json['tag_names'] ??
        json['tagNames'] ??
        json['labels'] ??
        json['tag_list'] ??
        json['category'] ??
        json['categories'] ??
        json['category_name'] ??
        json['category_id'] ??
        json['tagName'] ??
        json['tag'] ??
        json['label_names'] ??
        json['tag_id'];

    if (rawTags == null) return [];

    if (rawTags is String) {
      if (rawTags.trim().isEmpty) return [];
      // Handle comma or space separated strings
      final delimiter = rawTags.contains(',') ? ',' : ' ';
      return rawTags
          .split(delimiter)
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    if (rawTags is Map) {
      final name =
          (rawTags['name'] ??
                  rawTags['label'] ??
                  rawTags['tag_name'] ??
                  rawTags['title'] ??
                  rawTags['category_name'] ??
                  rawTags['text'] ??
                  rawTags['content'] ??
                  '')
              .toString();
      return name.isNotEmpty ? [name] : [];
    }

    if (rawTags is List) {
      return rawTags.map((e) {
        if (e is Map) {
          return (e['name'] ??
                  e['label'] ??
                  e['tag_name'] ??
                  e['title'] ??
                  e['category_name'] ??
                  e['text'] ??
                  e['content'] ??
                  '')
              .toString();
        }
        return e.toString();
      }).toList();
    }

    return [];
  }

  static TaskPriority _parsePriority(String? p) {
    if (p == null) return TaskPriority.medium;
    final lowerP = p.toLowerCase();
    return TaskPriority.values.firstWhere(
      (e) => e.name.toLowerCase() == lowerP,
      orElse: () => TaskPriority.medium,
    );
  }
}

class SubTaskModel extends SubTask {
  const SubTaskModel({required super.id, required super.title, super.isDone});

  factory SubTaskModel.fromJson(Map<String, dynamic> json) {
    return SubTaskModel(
      id: (json['subtask_id'] ?? json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      isDone:
          json['status'] == 'completed' ||
          json['completed'] == true ||
          json['is_done'] == true ||
          json['isDone'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {'title': title, 'completed': isDone};
  }
}
