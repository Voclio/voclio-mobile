import 'package:equatable/equatable.dart';

class TagEntity extends Equatable {
  final String id;
  final String name;
  final String color;
  final DateTime createdAt;

  const TagEntity({
    required this.id,
    required this.name,
    required this.color,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, name, color, createdAt];
}
