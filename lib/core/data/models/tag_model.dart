import 'package:voclio_app/core/domain/entities/tag_entity.dart';

class TagModel extends TagEntity {
  const TagModel({
    required super.id,
    required super.name,
    required super.color,
    super.description,
  });

  factory TagModel.fromJson(Map<String, dynamic> json) {
    return TagModel(
      id: (json['tag_id'] ?? json['id'] ?? '').toString(),
      name: json['name'] ?? '',
      color: json['color'] ?? '#3498db',
      description: json['description']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'color': color,
      if (description != null) 'description': description,
    };
  }

  TagEntity toEntity() {
    return TagEntity(
      id: id,
      name: name,
      color: color,
      description: description,
    );
  }
}
