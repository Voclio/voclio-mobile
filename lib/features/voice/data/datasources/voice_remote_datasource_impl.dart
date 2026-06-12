import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';
import 'package:voclio_app/core/api/api_client.dart';
import 'package:voclio_app/core/api/api_endpoints.dart';
import 'package:voclio_app/core/api/api_response.dart';
import 'package:voclio_app/core/app/language_controller.dart';
import 'voice_remote_datasource.dart';
import '../models/voice_recording_model.dart';

class VoiceRemoteDataSourceImpl implements VoiceRemoteDataSource {
  final ApiClient apiClient;

  VoiceRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<VoiceRecordingModel>> getVoiceRecordings() async {
    final response = await apiClient.get(ApiEndpoints.voiceRecordings);
    final list = ApiResponse.unwrapList(response.data, key: 'recordings');
    return list.map((e) => VoiceRecordingModel.fromJson(e)).toList();
  }

  @override
  Future<VoiceRecordingModel> uploadVoice(File file) async {
    try {
      return await _uploadViaProcessComplete(file);
    } on ServerException catch (e) {
      if (_shouldFallbackUpload(e.statusCode)) {
        return _uploadSimple(file);
      }
      debugPrint('PROCESS-COMPLETE ERROR: ${e.message}');
      rethrow;
    } on DioException catch (e) {
      if (_shouldFallbackUpload(e.response?.statusCode)) {
        return _uploadSimple(file);
      }
      debugPrint('PROCESS-COMPLETE ERROR: ${e.response?.data}');
      rethrow;
    }
  }

  bool _shouldFallbackUpload(int? statusCode) {
    return statusCode != null && statusCode >= 500;
  }

  /// Uses the app's selected language (Settings → Language).
  String get _transcriptionLanguage =>
      LanguageController.instance.currentLocale.value.languageCode;

  String _transcriptionFrom(Map<String, dynamic> recording) {
    final value = recording['transcription_text'] ?? recording['transcription'];
    return value?.toString().trim() ?? '';
  }

  MediaType _audioContentTypeFor(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.m4a')) {
      // AAC in MP4 container — widely accepted by servers and transcoders.
      return MediaType('audio', 'mp4');
    }
    if (lower.endsWith('.wav')) {
      return MediaType('audio', 'wav');
    }
    if (lower.endsWith('.mp3')) {
      return MediaType('audio', 'mpeg');
    }
    if (lower.endsWith('.webm')) {
      return MediaType('audio', 'webm');
    }
    if (lower.endsWith('.ogg')) {
      return MediaType('audio', 'ogg');
    }
    return MediaType('audio', 'mp4');
  }

  Future<FormData> _buildUploadFormData(File file) async {
    final fileName = file.path.split('/').last;
    final audioFile = await MultipartFile.fromFile(
      file.path,
      filename: fileName,
      contentType: _audioContentTypeFor(fileName),
    );

    return FormData.fromMap({
      'audio_file': audioFile,
      'language': _transcriptionLanguage,
      'auto_create_tasks': 'true',
      'auto_create_notes': 'true',
    });
  }

  Future<VoiceRecordingModel> _uploadViaProcessComplete(File file) async {
    final formData = await _buildUploadFormData(file);

    final response = await apiClient.uploadFile(
      ApiEndpoints.voiceProcessComplete,
      formData,
      options: Options(
        headers: {
          'Content-Type': 'multipart/form-data',
          'Accept': 'application/json',
        },
      ),
    );

    final data = ApiResponse.unwrapMap(response.data);
    final recordingId = data['recording_id']?.toString();
    final inlineTranscription = data['transcription']?.toString();
    final status = data['status']?.toString();

    if (recordingId != null && recordingId.isNotEmpty) {
      if (inlineTranscription != null && inlineTranscription.isNotEmpty) {
        final recording = await _getRecording(recordingId);
        recording['transcription_text'] = inlineTranscription;
        return VoiceRecordingModel.fromJson(recording);
      }

      if (status == 'processing') {
        final jobs = data['jobs'];
        final jobId = jobs is Map ? jobs['transcription']?.toString() : null;
        if (jobId != null && jobId.isNotEmpty) {
          final transcription = await _pollTranscriptionJob(jobId, recordingId);
          final recording = await _getRecording(recordingId);
          recording['transcription_text'] = transcription;
          return VoiceRecordingModel.fromJson(recording);
        }
      }

      final recording = await _getRecording(recordingId);
      return VoiceRecordingModel.fromJson(recording);
    }

    final recordingData = data['recording'] ?? data;
    return VoiceRecordingModel.fromJson(
      Map<String, dynamic>.from(recordingData as Map),
    );
  }

  Future<VoiceRecordingModel> _uploadSimple(File file) async {
    final fileName = file.path.split('/').last;

    final audioFile = await MultipartFile.fromFile(
      file.path,
      filename: fileName,
      contentType: _audioContentTypeFor(fileName),
    );

    final formData = FormData.fromMap({
      'audio_file': audioFile,
      'language': _transcriptionLanguage,
    });

    final response = await apiClient.uploadFile(
      ApiEndpoints.uploadVoice,
      formData,
      options: Options(
        headers: {
          'Content-Type': 'multipart/form-data',
          'Accept': 'application/json',
        },
      ),
    );

    final data = ApiResponse.unwrapMap(response.data);
    final recordingData = data['recording'] ?? data;
    return VoiceRecordingModel.fromJson(
      Map<String, dynamic>.from(recordingData as Map),
    );
  }

  @override
  Future<void> deleteVoice(String id) async {
    await apiClient.delete(ApiEndpoints.deleteVoice(id));
  }

  Future<Map<String, dynamic>> _getRecording(String id) async {
    final response = await apiClient.get(ApiEndpoints.voiceById(id));
    final data = ApiResponse.unwrapMap(response.data);
    return Map<String, dynamic>.from((data['recording'] ?? data) as Map);
  }

  @override
  Future<void> createNoteFromVoice(
    String id, {
    String? transcription,
  }) async {
    final text = transcription?.trim() ?? '';
    final resolved = text.isNotEmpty
        ? text
        : _transcriptionFrom(await _getRecording(id));
    if (resolved.isEmpty) {
      throw Exception('Recording is not transcribed yet');
    }

    await apiClient.post(
      ApiEndpoints.notes,
      data: {
        'title': 'Voice Note',
        'content': resolved,
        'voice_recording_id': int.tryParse(id) ?? id,
      },
    );
  }

  @override
  Future<void> createTasksFromVoice(
    String id, {
    String? transcription,
  }) async {
    final text = transcription?.trim() ?? '';
    final resolved = text.isNotEmpty
        ? text
        : _transcriptionFrom(await _getRecording(id));
    if (resolved.isEmpty) {
      throw Exception('Recording is not transcribed yet');
    }

    final noteResponse = await apiClient.post(
      ApiEndpoints.notes,
      data: {
        'title': 'Voice Tasks',
        'content': resolved,
        'voice_recording_id': int.tryParse(id) ?? id,
      },
    );

    final noteData = ApiResponse.unwrapMap(noteResponse.data);
    final note = noteData['note'] ?? noteData;
    final noteId = (note['note_id'] ?? note['id']).toString();

    final response = await apiClient.post(
      ApiEndpoints.extractTasksFromNote(noteId),
      data: {
        'auto_create': true,
        'default_due_if_missing': true,
        'discard_staging_note': true,
        'voice_recording_id': int.tryParse(id) ?? id,
      },
    );

    final data = ApiResponse.unwrapMap(response.data);
    final tasks = data['tasks'];
    final count = data['count'] is int
        ? data['count'] as int
        : (tasks is List ? tasks.length : 0);
    if (count == 0) {
      throw Exception(
        'Could not create a task from this recording. Try being more specific.',
      );
    }
  }

  @override
  Future<String> transcribe(String id) async {
    final recording = await _getRecording(id);
    final existing = _transcriptionFrom(recording);
    if (existing.isNotEmpty) {
      return existing;
    }

    final response = await apiClient.post(
      ApiEndpoints.transcribe,
      data: {
        'recording_id': int.tryParse(id) ?? id,
        'language': _transcriptionLanguage,
      },
    );

    final data = ApiResponse.unwrapMap(response.data);

    if (data['transcription'] != null) {
      return data['transcription'].toString();
    }

    final jobId = data['job_id']?.toString();
    if (jobId == null || jobId.isEmpty) {
      return '';
    }

    return _pollTranscriptionJob(jobId, id);
  }

  Future<String> _pollTranscriptionJob(String jobId, String recordingId) async {
    for (var attempt = 0; attempt < 30; attempt++) {
      await Future.delayed(const Duration(seconds: 2));

      final statusResponse = await apiClient.get(
        ApiEndpoints.voiceJobStatus(jobId),
        queryParameters: {'queue': 'transcription'},
      );
      final statusData = ApiResponse.unwrapMap(statusResponse.data);
      final job = statusData['job'] as Map? ?? statusData;
      final state = job['state']?.toString();

      if (state == 'completed') {
        final result = job['result'];
        if (result is Map && result['transcription'] != null) {
          return result['transcription'].toString();
        }
        final recording = await _getRecording(recordingId);
        return recording['transcription_text']?.toString() ?? '';
      }

      if (state == 'failed') {
        throw Exception(job['error']?.toString() ?? 'Transcription failed');
      }
    }

    throw Exception('Transcription timed out. Ensure the worker is running.');
  }

  @override
  Future<void> updateTranscription({
    required String recordingId,
    required String transcription,
  }) async {
    debugPrint("UPDATING TRANSCRIPTION FOR ID: $recordingId");

    await apiClient.put(
      ApiEndpoints.voiceUpdateTranscription,
      data: {'recording_id': recordingId, 'transcription': transcription},
    );

    debugPrint("TRANSCRIPTION UPDATED SUCCESSFULLY");
  }
}
