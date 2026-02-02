import 'package:equatable/equatable.dart';
import 'package:voclio_app/core/enums/enums.dart'; // Helps with state comparison

class TaskEntity extends Equatable {
  final String id;
  final String title;
  final String? description;
  final DateTime date; // The Due Date
  final DateTime createdAt;
  final bool isDone;
  final TaskPriority priority;
  final List<SubTask> subtasks;
  final List<String> tags;
  final String? relatedNoteId; // Links to a Note

  const TaskEntity({
    required this.id,
    required this.title,
    required this.date,
    required this.createdAt,
    this.description,
    this.isDone = false,
    this.priority = TaskPriority.none,
    this.subtasks = const [],
    this.tags = const [],
    this.relatedNoteId,
  });

  TaskEntity copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    DateTime? createdAt,
    bool? isDone,
    TaskPriority? priority,
    List<SubTask>? subtasks,
    List<String>? tags,
    String? relatedNoteId,
  }) {
    return TaskEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      isDone: isDone ?? this.isDone,
      priority: priority ?? this.priority,
      subtasks: subtasks ?? this.subtasks,
      tags: tags ?? this.tags,
      relatedNoteId: relatedNoteId ?? this.relatedNoteId,
    );
  }

  // Calculate progress for the UI (e.g., "1/3")
  int get completedSubtasks => subtasks.where((s) => s.isDone).length;
  int get totalSubtasks => subtasks.length;
  double get progress =>
      totalSubtasks == 0 ? 0 : completedSubtasks / totalSubtasks;

  @override
  List<Object?> get props => [id, title, isDone, subtasks, tags, relatedNoteId];
}

class SubTask extends Equatable {
  final String id;
  final String title;
  final bool isDone;

  const SubTask({required this.id, required this.title, this.isDone = false});

  @override
  List<Object?> get props => [id, title, isDone];

  SubTask copyWith({String? id, String? title, bool? isDone}) {
    return SubTask(
      id: id ?? this.id,
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
    );
  }
}
