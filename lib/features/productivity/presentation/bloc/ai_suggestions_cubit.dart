import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:translator/translator.dart';
import 'package:voclio_app/features/productivity/domain/usecases/get_ai_suggestions_usecase.dart';
import 'package:voclio_app/features/productivity/presentation/bloc/ai_suggestions_state.dart';

class AiSuggestionsCubit extends Cubit<AiSuggestionsState> {
  final GetAiSuggestionsUseCase getAiSuggestionsUseCase;
  final GoogleTranslator _translator = GoogleTranslator();

  AiSuggestionsCubit({required this.getAiSuggestionsUseCase})
    : super(AiSuggestionsInitial());

  Future<void> loadAiSuggestions() async {
    emit(AiSuggestionsLoading());
    final result = await getAiSuggestionsUseCase();

    await result.fold(
      (failure) async => emit(
        const AiSuggestionsError(message: 'Failed to load AI suggestions'),
      ),
      (suggestionsEntity) async {
        try {
          // Force translation to English as requested
          const targetLang = 'en';

          // Translate each suggestion
          final translatedSuggestions = await Future.wait(
            suggestionsEntity.suggestions.map((s) async {
              final translation = await _translator.translate(
                s,
                to: targetLang,
              );
              return translation.text;
            }),
          );

          // Emit the entity with translated suggestions
          emit(
            AiSuggestionsLoaded(
              suggestions: suggestionsEntity.copyWith(
                suggestions: translatedSuggestions,
              ),
            ),
          );
        } catch (e) {
          // If translation fails, emit with original suggestions
          emit(AiSuggestionsLoaded(suggestions: suggestionsEntity));
        }
      },
    );
  }
}
