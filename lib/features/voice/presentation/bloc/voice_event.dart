import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class VoiceEvent extends Equatable {
  const VoiceEvent();

  @override
  List<Object?> get props => [];
}

class LoadVoiceRecordings extends VoiceEvent {}

class UploadVoiceFile extends VoiceEvent {
  final File file;

  const UploadVoiceFile(this.file);

  @override
  List<Object?> get props => [file];
}

class DeleteVoiceRecording extends VoiceEvent {
  final String id;

  const DeleteVoiceRecording(this.id);

  @override
  List<Object?> get props => [id];
}

class CreateNoteFromVoice extends VoiceEvent {
  final String id;
  final String? transcription;

  const CreateNoteFromVoice(this.id, {this.transcription});

  @override
  List<Object?> get props => [id, transcription];
}

class CreateTasksFromVoice extends VoiceEvent {
  final String id;
  final String? transcription;

  const CreateTasksFromVoice(this.id, {this.transcription});

  @override
  List<Object?> get props => [id, transcription];
}

class TranscribeVoice extends VoiceEvent {
  final String id;

  const TranscribeVoice(this.id);

  @override
  List<Object?> get props => [id];
}

class UpdateTranscription extends VoiceEvent {
  final String recordingId;
  final String transcription;

  const UpdateTranscription({
    required this.recordingId,
    required this.transcription,
  });

  @override
  List<Object?> get props => [recordingId, transcription];
}
