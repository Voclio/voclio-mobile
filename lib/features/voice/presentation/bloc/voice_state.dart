import 'package:equatable/equatable.dart';
import '../../domain/entities/voice_recording.dart';

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
