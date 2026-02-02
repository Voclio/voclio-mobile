import 'package:equatable/equatable.dart';

class TagEntity extends Equatable {
  final String id;
  final String name;
  final String color;
  final String? description;

  const TagEntity({
    required this.id,
    required this.name,
    required this.color,
    this.description,
  });

  @override
  List<Object?> get props => [id, name, color, description];
}
