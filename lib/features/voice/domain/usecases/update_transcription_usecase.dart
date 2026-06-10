import 'package:dartz/dartz.dart';
import 'package:voclio_app/core/errors/failures.dart';
import '../repositories/voice_repository.dart';

class UpdateTranscriptionUseCase {
  final VoiceRepository repository;

  UpdateTranscriptionUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String recordingId,
    required String transcription,
  }) async {
    return await repository.updateTranscription(
      recordingId: recordingId,
      transcription: transcription,
    );
  }
}
