import 'package:dartz/dartz.dart';
import 'package:voclio_app/core/errors/failures.dart';
import '../repositories/voice_repository.dart';

class TranscribeVoiceUseCase {
  final VoiceRepository repository;

  TranscribeVoiceUseCase(this.repository);

  Future<Either<Failure, String>> call(String id) async {
    return await repository.transcribe(id);
  }
}
