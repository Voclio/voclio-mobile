import 'package:voclio_app/features/notes/domain/entities/note_entity.dart';

class NoteModel extends NoteEntity {
  const NoteModel({
    required super.id,
    required super.title,
    required super.content,
    required super.lastEditDate,
    required super.creationDate,
    super.tags,
    super.voiceToTextDuration,
    super.categoryId,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: (json['note_id'] ?? json['id'] ?? '').toString(),
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      lastEditDate: DateTime.parse(
        json['updated_at'] ??
            json['lastEditDate'] ??
            json['last_edit_date'] ??
            DateTime.now().toIso8601String(),
      ),
      creationDate: DateTime.parse(
        json['created_at'] ??
            json['creationDate'] ??
            json['creation_date'] ??
            DateTime.now().toIso8601String(),
      ),
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) {
            if (e is Map) {
              return (e['name'] ?? e['label'] ?? '').toString();
            }
            return e.toString();
          }).toList() ??
          [],
      voiceToTextDuration:
          (json['voice_to_text_duration'] ?? json['voiceToTextDuration'])
              ?.toString(),
      categoryId: json['category_id'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      if (tags.isNotEmpty) 'tags': tags,
      if (categoryId != null) 'category_id': categoryId,
    };
  }
}
