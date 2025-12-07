part of 'tag_cubit.dart';

abstract class TagState {}

class TagInitial extends TagState {}

class TagLoading extends TagState {}

class TagLoaded extends TagState {
  final List<TagEntity> tags;

  TagLoaded(this.tags);
}

class TagError extends TagState {
  final String message;

  TagError(this.message);
}
