import 'package:equatable/equatable.dart';

class VoiceRecording extends Equatable {
  final String id;
  final String title;
  final String url;
  final String? transcription;
  final Duration duration;
  final DateTime createdAt;

  const VoiceRecording({
    required this.id,
    required this.title,
    required this.url,
    this.transcription,
    required this.duration,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, title, url, transcription, duration, createdAt];
}
