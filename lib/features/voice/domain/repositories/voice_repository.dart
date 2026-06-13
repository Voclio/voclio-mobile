import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:voclio_app/core/errors/failures.dart';
import '../entities/voice_recording.dart';

abstract class VoiceRepository {
  Future<Either<Failure, List<VoiceRecording>>> getVoiceRecordings();
  Future<Either<Failure, VoiceRecording>> uploadVoice(File file);
  Future<Either<Failure, void>> deleteVoice(String id);
  Future<Either<Failure, void>> createNoteFromVoice(
    String id, {
    String? transcription,
  });
  Future<Either<Failure, DateTime?>> createTasksFromVoice(
    String id, {
    String? transcription,
  });
  Future<Either<Failure, String>> transcribe(String id);
  Future<Either<Failure, void>> updateTranscription({
    required String recordingId,
    required String transcription,
  });
}
