import 'package:dartz/dartz.dart';
import 'package:voclio_app/core/errors/failures.dart';
import '../repositories/voice_repository.dart';
import '../entities/voice_extraction.dart';

class CreateFromPreviewUseCase {
  final VoiceRepository repository;

  CreateFromPreviewUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required List<ExtractedTask> tasks,
    required List<ExtractedNote> notes,
  }) async {
    return await repository.createFromPreview(tasks: tasks, notes: notes);
  }
}
