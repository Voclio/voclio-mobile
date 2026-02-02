import 'package:voclio_app/features/tags/domain/entities/tag_entity.dart';

class TagModel {
  final String id;
  final String name;
  final String color;
  final String? description;
  final DateTime createdAt;

  TagModel({
    required this.id,
    required this.name,
    required this.color,
    this.description,
    required this.createdAt,
  });

  factory TagModel.fromJson(Map<String, dynamic> json) {
    return TagModel(
      id: (json['tag_id'] ?? json['id'] ?? '').toString(),
      name: json['name'] ?? '',
      color: json['color'] ?? '#6B46C1',
      description: json['description'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
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
      createdAt: createdAt,
    );
  }

  factory TagModel.fromEntity(TagEntity entity) {
    return TagModel(
      id: entity.id,
      name: entity.name,
      color: entity.color,
      description: entity.description,
      createdAt: entity.createdAt,
    );
  }
}
