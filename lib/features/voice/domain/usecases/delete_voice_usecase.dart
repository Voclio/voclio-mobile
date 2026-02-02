import 'package:dartz/dartz.dart';
import 'package:voclio_app/core/errors/failures.dart';
import '../repositories/voice_repository.dart';

class DeleteVoiceUseCase {
  final VoiceRepository repository;

  DeleteVoiceUseCase(this.repository);

  Future<Either<Failure, void>> call(String id) async {
    return await repository.deleteVoice(id);
  }
}
