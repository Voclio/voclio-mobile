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

  const CreateNoteFromVoice(this.id);

  @override
  List<Object?> get props => [id];
}

class CreateTasksFromVoice extends VoiceEvent {
  final String id;

  const CreateTasksFromVoice(this.id);

  @override
  List<Object?> get props => [id];
}

class TranscribeVoice extends VoiceEvent {
  final String id;

  const TranscribeVoice(this.id);

  @override
  List<Object?> get props => [id];
}
