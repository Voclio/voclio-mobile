import 'dart:io';
import '../models/voice_recording_model.dart';

abstract class VoiceRemoteDataSource {
  Future<List<VoiceRecordingModel>> getVoiceRecordings();
  Future<VoiceRecordingModel> uploadVoice(File file);
  Future<void> deleteVoice(String id);
  Future<void> createNoteFromVoice(String id);
  Future<void> createTasksFromVoice(String id);
  Future<String> transcribe(String id);
}
