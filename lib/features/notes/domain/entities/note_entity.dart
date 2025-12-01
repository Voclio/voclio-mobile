import 'package:equatable/equatable.dart';
import 'package:voclio_app/core/enums/enums.dart';

class NoteEntity extends Equatable {
  final String id;
  final String title;
  final String content; // The actual note body
  final DateTime lastEditDate;
  final DateTime creationDate;
  final List<AppTag> tags;
  final String? voiceToTextDuration; // e.g. "02:15"

  const NoteEntity({
    required this.id,
    required this.title,
    required this.content,
    required this.lastEditDate,
    required this.creationDate,
    this.tags = const [],
    this.voiceToTextDuration,
  });

  NoteEntity copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? lastEditDate,
    DateTime? creationDate,
    List<AppTag>? tags,
    String? voiceToTextDuration,
  }) {
    return NoteEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      lastEditDate: lastEditDate ?? this.lastEditDate,
      creationDate: creationDate ?? this.creationDate,
      tags: tags ?? this.tags,
      voiceToTextDuration: voiceToTextDuration ?? this.voiceToTextDuration,
    );
  }

  @override
  List<Object?> get props => [id, title, lastEditDate, tags];
}
