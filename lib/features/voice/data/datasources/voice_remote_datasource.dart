import 'dart:io';
import '../models/voice_recording_model.dart';

abstract class VoiceRemoteDataSource {
  Future<List<VoiceRecordingModel>> getVoiceRecordings();
  Future<VoiceRecordingModel> getVoiceById(String id);
  Future<VoiceRecordingModel> uploadVoice(File file);
  Future<void> deleteVoice(String id);
  Future<void> createNoteFromVoice(String id);
  Future<void> createTasksFromVoice(String id);
  Future<String> transcribe(String id);
  
  // Advanced Voice Features
  Future<Map<String, dynamic>> processComplete(File file);
  Future<Map<String, dynamic>> previewExtraction(String transcription);
  Future<Map<String, dynamic>> createFromPreview(List<Map<String, dynamic>> tasks, List<Map<String, dynamic>> notes);
  Future<void> updateTranscription(String voiceId, String transcription);
}
