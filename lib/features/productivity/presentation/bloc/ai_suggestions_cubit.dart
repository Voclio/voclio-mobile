import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voclio_app/features/productivity/domain/usecases/get_ai_suggestions_usecase.dart';
import 'package:voclio_app/features/productivity/presentation/bloc/ai_suggestions_state.dart';

class AiSuggestionsCubit extends Cubit<AiSuggestionsState> {
  final GetAiSuggestionsUseCase getAiSuggestionsUseCase;

  String? _loadedForUserKey;

  AiSuggestionsCubit({required this.getAiSuggestionsUseCase})
    : super(AiSuggestionsInitial());

  void reset() {
    _loadedForUserKey = null;
    emit(AiSuggestionsInitial());
  }

  Future<void> loadAiSuggestions({
    bool force = false,
    String? userKey,
    String language = 'en',
  }) async {
    if (!force &&
        state is AiSuggestionsLoaded &&
        userKey != null &&
        userKey == _loadedForUserKey) {
      return;
    }

    final hasExistingInsight = state is AiSuggestionsLoaded;
    if (!hasExistingInsight) {
      emit(AiSuggestionsLoading());
    }

    final result = await getAiSuggestionsUseCase(language: language);

    result.fold(
      (failure) {
        if (hasExistingInsight) return;
        emit(
          const AiSuggestionsError(message: 'Failed to load AI suggestions'),
        );
      },
      (suggestionsEntity) {
        _loadedForUserKey = userKey;
        emit(AiSuggestionsLoaded(suggestions: suggestionsEntity));
      },
    );
  }
}
