import 'package:dartz/dartz.dart';
import 'package:voclio_app/core/errors/failures.dart';
import '../repositories/voice_repository.dart';
import '../entities/voice_recording.dart';

class GetVoiceRecordingsUseCase {
  final VoiceRepository repository;

  GetVoiceRecordingsUseCase(this.repository);

  Future<Either<Failure, List<VoiceRecording>>> call() async {
    return await repository.getVoiceRecordings();
  }
}
