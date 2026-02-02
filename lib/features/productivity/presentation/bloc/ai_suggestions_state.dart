import 'package:equatable/equatable.dart';
import 'package:voclio_app/features/productivity/domain/entities/ai_suggestion_entity.dart';

abstract class AiSuggestionsState extends Equatable {
  const AiSuggestionsState();

  @override
  List<Object?> get props => [];
}

class AiSuggestionsInitial extends AiSuggestionsState {}

class AiSuggestionsLoading extends AiSuggestionsState {}

class AiSuggestionsLoaded extends AiSuggestionsState {
  final AiSuggestionEntity suggestions;

  const AiSuggestionsLoaded({required this.suggestions});

  @override
  List<Object?> get props => [suggestions];
}

class AiSuggestionsError extends AiSuggestionsState {
  final String message;

  const AiSuggestionsError({required this.message});

  @override
  List<Object?> get props => [message];
}
