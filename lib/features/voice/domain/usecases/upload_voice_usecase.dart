import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:voclio_app/core/errors/failures.dart';
import '../repositories/voice_repository.dart';
import '../entities/voice_recording.dart';

class UploadVoiceUseCase {
  final VoiceRepository repository;

  UploadVoiceUseCase(this.repository);

  Future<Either<Failure, VoiceRecording>> call(File file) async {
    return await repository.uploadVoice(file);
  }
}
