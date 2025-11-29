import 'package:voclio_app/core/enums/enums.dart';
import 'package:voclio_app/features/tasks/domain/entities/note_entity.dart';

class NoteModel extends NoteEntity {
  const NoteModel({
    required super.id,
    required super.title,
    required super.content,
    required super.lastEditDate,
    required super.creationDate,
    super.tags,
    super.voiceToTextDuration,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      lastEditDate: DateTime.parse(json['lastEditDate']),
      creationDate: DateTime.parse(json['creationDate']),
      tags:
          (json['tags'] as List<dynamic>?)
              ?.map((e) => _parseTag(e.toString()))
              .toList() ??
          [],
      voiceToTextDuration: json['voiceToTextDuration'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'lastEditDate': lastEditDate.toIso8601String(),
      'creationDate': creationDate.toIso8601String(),
      'tags': tags.map((e) => e.name).toList(),
      'voiceToTextDuration': voiceToTextDuration,
    };
  }

  static AppTag _parseTag(String t) {
    return AppTag.values.firstWhere(
      (e) => e.name == t,
      orElse: () => AppTag.personal, // Default tag
    );
  }
}
