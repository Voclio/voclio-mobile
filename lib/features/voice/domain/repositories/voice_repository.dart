import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:voclio_app/core/errors/failures.dart';
import '../entities/voice_recording.dart';
import '../entities/voice_extraction.dart';

abstract class VoiceRepository {
  Future<Either<Failure, List<VoiceRecording>>> getVoiceRecordings();
  Future<Either<Failure, VoiceRecording>> uploadVoice(File file);
  Future<Either<Failure, void>> deleteVoice(String id);
  Future<Either<Failure, void>> createNoteFromVoice(String id);
  Future<Either<Failure, void>> createTasksFromVoice(String id);
  Future<Either<Failure, String>> transcribe(String id);
  
  // New: Preview extraction before creating
  Future<Either<Failure, VoiceExtraction>> previewExtraction(String transcription);
  Future<Either<Failure, void>> createFromPreview({
    required List<ExtractedTask> tasks,
    required List<ExtractedNote> notes,
  });
}
