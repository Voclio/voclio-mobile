import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';
import 'package:voclio_app/core/api/api_client.dart';
import 'package:voclio_app/core/api/api_endpoints.dart';
import 'package:voclio_app/core/api/api_response.dart';
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
      if (e.statusCode == 503) {
        return _uploadSimple(file);
      }
      debugPrint('PROCESS-COMPLETE ERROR: ${e.message}');
      rethrow;
    } on DioException catch (e) {
      if (e.response?.statusCode == 503) {
        return _uploadSimple(file);
      }
      debugPrint('PROCESS-COMPLETE ERROR: ${e.response?.data}');
      rethrow;
    }
  }

  Future<FormData> _buildUploadFormData(File file) async {
    final fileName = file.path.split('/').last;
    final audioFile = await MultipartFile.fromFile(
      file.path,
      filename: fileName,
      contentType: MediaType('audio', 'mp4'),
    );

    return FormData.fromMap({
      'audio_file': audioFile,
      'language': 'ar',
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
    if (recordingId != null && recordingId.isNotEmpty) {
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
      contentType: MediaType('audio', 'mp4'),
    );

    final formData = FormData.fromMap({
      'audio_file': audioFile,
      'language': 'ar',
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
  Future<void> createNoteFromVoice(String id) async {
    final recording = await _getRecording(id);
    final transcription = recording['transcription_text']?.toString() ?? '';
    if (transcription.isEmpty) {
      throw Exception('Recording is not transcribed yet');
    }

    await apiClient.post(
      ApiEndpoints.notes,
      data: {
        'title': 'Voice Note',
        'content': transcription,
        'voice_recording_id': int.tryParse(id) ?? id,
      },
    );
  }

  @override
  Future<void> createTasksFromVoice(String id) async {
    final recording = await _getRecording(id);
    final transcription = recording['transcription_text']?.toString() ?? '';
    if (transcription.isEmpty) {
      throw Exception('Recording is not transcribed yet');
    }

    final noteResponse = await apiClient.post(
      ApiEndpoints.notes,
      data: {
        'title': 'Voice Tasks',
        'content': transcription,
        'voice_recording_id': int.tryParse(id) ?? id,
      },
    );

    final noteData = ApiResponse.unwrapMap(noteResponse.data);
    final note = noteData['note'] ?? noteData;
    final noteId = (note['note_id'] ?? note['id']).toString();

    await apiClient.post(
      ApiEndpoints.extractTasksFromNote(noteId),
      data: {'auto_create': true},
    );
  }

  @override
  Future<String> transcribe(String id) async {
    final recording = await _getRecording(id);
    final existing = recording['transcription_text']?.toString() ?? '';
    if (existing.isNotEmpty) {
      return existing;
    }

    final response = await apiClient.post(
      ApiEndpoints.transcribe,
      data: {
        'recording_id': int.tryParse(id) ?? id,
        'language': 'ar',
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
