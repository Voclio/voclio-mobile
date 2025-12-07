import '../../domain/entities/tag_entity.dart';

class TagModel {
  final String id;
  final String name;
  final String color;
  final DateTime createdAt;

  TagModel({
    required this.id,
    required this.name,
    required this.color,
    required this.createdAt,
  });

  factory TagModel.fromJson(Map<String, dynamic> json) {
    return TagModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      color: json['color'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'color': color};
  }

  TagEntity toEntity() {
    return TagEntity(id: id, name: name, color: color, createdAt: createdAt);
  }

  factory TagModel.fromEntity(TagEntity entity) {
    return TagModel(
      id: entity.id,
      name: entity.name,
      color: entity.color,
      createdAt: entity.createdAt,
    );
  }
}
