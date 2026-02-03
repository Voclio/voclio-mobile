import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:voclio_app/core/errors/failures.dart';
import '../entities/voice_recording.dart';

abstract class VoiceRepository {
  Future<Either<Failure, List<VoiceRecording>>> getVoiceRecordings();
  Future<Either<Failure, VoiceRecording>> uploadVoice(File file);
  Future<Either<Failure, void>> deleteVoice(String id);
  Future<Either<Failure, void>> createNoteFromVoice(String id);
  Future<Either<Failure, void>> createTasksFromVoice(String id);
  Future<Either<Failure, String>> transcribe(String id);
}
