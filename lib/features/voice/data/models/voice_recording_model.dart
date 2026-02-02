import '../../domain/entities/voice_recording.dart';

class VoiceRecordingModel extends VoiceRecording {
  const VoiceRecordingModel({
    required super.id,
    required super.title,
    required super.url,
    super.transcription,
    required super.duration,
    required super.createdAt,
  });

  factory VoiceRecordingModel.fromJson(Map<String, dynamic> json) {
    return VoiceRecordingModel(
      id: (json['recording_id'] ?? json['id'] ?? json['_id'] ?? '').toString(),
      title: (json['title'] ?? 'New Recording') as String,
      url: (json['url'] ?? json['path'] ?? json['audio_url'] ?? '') as String,
      transcription:
          json['transcription'] ?? json['transcription_text'] as String?,
      duration: Duration(
        seconds:
            (json['duration'] is num)
                ? (json['duration'] as num).toInt()
                : int.tryParse(json['duration']?.toString() ?? '0') ?? 0,
      ),
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'] as String)
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'url': url,
      'transcription': transcription,
      'duration': duration.inSeconds,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
