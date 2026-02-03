import 'package:equatable/equatable.dart';

class NoteEntity extends Equatable {
  final String id;
  final String title;
  final String content; // The actual note body
  final DateTime lastEditDate;
  final DateTime creationDate;
  final List<String> tags;
  final String? voiceToTextDuration; // e.g. "02:15"
  final int? categoryId;

  const NoteEntity({
    required this.id,
    required this.title,
    required this.content,
    required this.lastEditDate,
    required this.creationDate,
    this.tags = const [],
    this.voiceToTextDuration,
    this.categoryId,
  });

  NoteEntity copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? lastEditDate,
    DateTime? creationDate,
    List<String>? tags,
    String? voiceToTextDuration,
    int? categoryId,
  }) {
    return NoteEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      lastEditDate: lastEditDate ?? this.lastEditDate,
      creationDate: creationDate ?? this.creationDate,
      tags: tags ?? this.tags,
      voiceToTextDuration: voiceToTextDuration ?? this.voiceToTextDuration,
      categoryId: categoryId ?? this.categoryId,
    );
  }

  @override
  List<Object?> get props => [id, title, lastEditDate, tags, categoryId];
}
