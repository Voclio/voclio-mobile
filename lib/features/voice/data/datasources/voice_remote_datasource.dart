import 'dart:io';
import '../models/voice_recording_model.dart';

abstract class VoiceRemoteDataSource {
  Future<List<VoiceRecordingModel>> getVoiceRecordings();
  Future<VoiceRecordingModel> uploadVoice(File file);
  Future<void> deleteVoice(String id);
  Future<void> createNoteFromVoice(String id, {String? transcription});
  Future<DateTime?> createTasksFromVoice(String id, {String? transcription});
  Future<String> transcribe(String id);
  Future<void> updateTranscription({
    required String recordingId,
    required String transcription,
  });
}
