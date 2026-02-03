import 'package:equatable/equatable.dart';

/// Represents extracted content from voice transcription
class VoiceExtraction extends Equatable {
  final List<ExtractedTask> tasks;
  final List<ExtractedNote> notes;

  const VoiceExtraction({
    this.tasks = const [],
    this.notes = const [],
  });

  VoiceExtraction copyWith({
    List<ExtractedTask>? tasks,
    List<ExtractedNote>? notes,
  }) {
    return VoiceExtraction(
      tasks: tasks ?? this.tasks,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [tasks, notes];
}

/// Task extracted from voice by AI
class ExtractedTask extends Equatable {
  final String id;
  final String title;
  final String? description;
  final DateTime? dueDate;
  final String priority; // 'high', 'medium', 'low', 'none'
  final bool isSelected;

  const ExtractedTask({
    required this.id,
    required this.title,
    this.description,
    this.dueDate,
    this.priority = 'none',
    this.isSelected = true,
  });

  ExtractedTask copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    String? priority,
    bool? isSelected,
  }) {
    return ExtractedTask(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'due_date': dueDate?.toIso8601String(),
      'priority': priority,
    };
  }

  factory ExtractedTask.fromJson(Map<String, dynamic> json, int index) {
    return ExtractedTask(
      id: 'temp_task_$index',
      title: json['title'] ?? 'Untitled Task',
      description: json['description'],
      dueDate: json['due_date'] != null 
          ? DateTime.tryParse(json['due_date'].toString()) 
          : null,
      priority: json['priority'] ?? 'none',
      isSelected: true,
    );
  }

  @override
  List<Object?> get props => [id, title, description, dueDate, priority, isSelected];
}

/// Note extracted from voice by AI
class ExtractedNote extends Equatable {
  final String id;
  final String title;
  final String content;
  final List<String> tags;
  final bool isSelected;

  const ExtractedNote({
    required this.id,
    required this.title,
    required this.content,
    this.tags = const [],
    this.isSelected = true,
  });

  ExtractedNote copyWith({
    String? id,
    String? title,
    String? content,
    List<String>? tags,
    bool? isSelected,
  }) {
    return ExtractedNote(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      tags: tags ?? this.tags,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'tags': tags,
    };
  }

  factory ExtractedNote.fromJson(Map<String, dynamic> json, int index) {
    return ExtractedNote(
      id: 'temp_note_$index',
      title: json['title'] ?? 'Untitled Note',
      content: json['content'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      isSelected: true,
    );
  }

  @override
  List<Object?> get props => [id, title, content, tags, isSelected];
}
