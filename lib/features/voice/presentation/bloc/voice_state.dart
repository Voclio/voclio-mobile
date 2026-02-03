import 'package:equatable/equatable.dart';
import '../../domain/entities/voice_recording.dart';
import '../../domain/entities/voice_extraction.dart';

abstract class VoiceState extends Equatable {
  const VoiceState();
  
  @override
  List<Object?> get props => [];
}

class VoiceInitial extends VoiceState {}

class VoiceLoading extends VoiceState {
  final String message;

  const VoiceLoading([this.message = 'Processing...']);

  @override
  List<Object?> get props => [message];
}

class VoiceLoaded extends VoiceState {
  final List<VoiceRecording> recordings;

  const VoiceLoaded(this.recordings);

  @override
  List<Object?> get props => [recordings];
}

class VoiceTranscriptionLoaded extends VoiceState {
  final String transcription;
  final String recordingId;

  const VoiceTranscriptionLoaded(this.transcription, this.recordingId);

  @override
  List<Object?> get props => [transcription, recordingId];
}

class VoiceOperationSuccess extends VoiceState {
  final String message;

  const VoiceOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class VoiceError extends VoiceState {
  final String message;

  const VoiceError(this.message);

  @override
  List<Object?> get props => [message];
}

// New state for extraction preview
class VoiceExtractionLoaded extends VoiceState {
  final String transcription;
  final String recordingId;
  final VoiceExtraction extraction;

  const VoiceExtractionLoaded({
    required this.transcription,
    required this.recordingId,
    required this.extraction,
  });

  VoiceExtractionLoaded copyWith({
    String? transcription,
    String? recordingId,
    VoiceExtraction? extraction,
  }) {
    return VoiceExtractionLoaded(
      transcription: transcription ?? this.transcription,
      recordingId: recordingId ?? this.recordingId,
      extraction: extraction ?? this.extraction,
    );
  }

  @override
  List<Object?> get props => [transcription, recordingId, extraction];
}

class VoiceExtractionLoading extends VoiceState {
  final String transcription;
  final String recordingId;
  final String message;

  const VoiceExtractionLoading({
    required this.transcription,
    required this.recordingId,
    this.message = 'AI is analyzing your voice...',
  });

  @override
  List<Object?> get props => [transcription, recordingId, message];
}

class VoiceCreatingFromPreview extends VoiceState {
  final String message;

  const VoiceCreatingFromPreview([this.message = 'Creating items...']);

  @override
  List<Object?> get props => [message];
}

