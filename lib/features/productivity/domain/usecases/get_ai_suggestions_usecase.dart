import 'package:dartz/dartz.dart';
import 'package:voclio_app/core/errors/failures.dart';
import 'package:voclio_app/features/productivity/domain/entities/ai_suggestion_entity.dart';
import 'package:voclio_app/features/productivity/domain/repositories/productivity_repository.dart';

class GetAiSuggestionsUseCase {
  final ProductivityRepository repository;

  GetAiSuggestionsUseCase(this.repository);

  Future<Either<Failure, AiSuggestionEntity>> call() async {
    return await repository.getAiSuggestions();
  }
}
