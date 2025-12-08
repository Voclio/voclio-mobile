import 'package:equatable/equatable.dart';
import '../../domain/entities/tag_entity.dart';

abstract class TagsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TagsInitial extends TagsState {}

class TagsLoading extends TagsState {}

class TagsLoaded extends TagsState {
  final List<TagEntity> tags;

  TagsLoaded(this.tags);

  @override
  List<Object?> get props => [tags];
}

class TagCreated extends TagsState {
  final TagEntity tag;

  TagCreated(this.tag);

  @override
  List<Object?> get props => [tag];
}

class TagUpdated extends TagsState {
  final TagEntity tag;

  TagUpdated(this.tag);

  @override
  List<Object?> get props => [tag];
}

class TagDeleted extends TagsState {
  final String id;

  TagDeleted(this.id);

  @override
  List<Object?> get props => [id];
}

class TagsError extends TagsState {
  final String message;

  TagsError(this.message);

  @override
  List<Object?> get props => [message];
}
