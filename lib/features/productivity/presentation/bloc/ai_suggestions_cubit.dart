import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voclio_app/features/productivity/domain/usecases/get_ai_suggestions_usecase.dart';
import 'package:voclio_app/features/productivity/presentation/bloc/ai_suggestions_state.dart';

class AiSuggestionsCubit extends Cubit<AiSuggestionsState> {
  final GetAiSuggestionsUseCase getAiSuggestionsUseCase;

  AiSuggestionsCubit({required this.getAiSuggestionsUseCase})
    : super(AiSuggestionsInitial());

  Future<void> loadAiSuggestions({bool force = false}) async {
    if (!force && state is AiSuggestionsLoaded) return;

    emit(AiSuggestionsLoading());
    final result = await getAiSuggestionsUseCase();

    result.fold(
      (failure) => emit(
        const AiSuggestionsError(message: 'Failed to load AI suggestions'),
      ),
      (suggestionsEntity) =>
          emit(AiSuggestionsLoaded(suggestions: suggestionsEntity)),
    );
  }
}
