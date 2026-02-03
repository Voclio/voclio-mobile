import 'dart:io';
import 'package:equatable/equatable.dart';
import '../../domain/entities/voice_extraction.dart';

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

// New events for preview extraction
class PreviewExtractionEvent extends VoiceEvent {
  final String transcription;

  const PreviewExtractionEvent(this.transcription);

  @override
  List<Object?> get props => [transcription];
}

class UpdateExtractedTask extends VoiceEvent {
  final ExtractedTask task;

  const UpdateExtractedTask(this.task);

  @override
  List<Object?> get props => [task];
}

class UpdateExtractedNote extends VoiceEvent {
  final ExtractedNote note;

  const UpdateExtractedNote(this.note);

  @override
  List<Object?> get props => [note];
}

class ToggleTaskSelection extends VoiceEvent {
  final String taskId;

  const ToggleTaskSelection(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

class ToggleNoteSelection extends VoiceEvent {
  final String noteId;

  const ToggleNoteSelection(this.noteId);

  @override
  List<Object?> get props => [noteId];
}

class CreateFromPreviewEvent extends VoiceEvent {
  final List<ExtractedTask> tasks;
  final List<ExtractedNote> notes;

  const CreateFromPreviewEvent({
    required this.tasks,
    required this.notes,
  });

  @override
  List<Object?> get props => [tasks, notes];
}

class ClearExtraction extends VoiceEvent {}

