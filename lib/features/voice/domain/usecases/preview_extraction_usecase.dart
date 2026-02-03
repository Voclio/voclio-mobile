import 'package:dartz/dartz.dart';
import 'package:voclio_app/core/errors/failures.dart';
import '../repositories/voice_repository.dart';
import '../entities/voice_extraction.dart';

class PreviewExtractionUseCase {
  final VoiceRepository repository;

  PreviewExtractionUseCase(this.repository);

  Future<Either<Failure, VoiceExtraction>> call(String transcription) async {
    return await repository.previewExtraction(transcription);
  }
}
