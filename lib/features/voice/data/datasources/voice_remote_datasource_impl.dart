import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';
import 'package:voclio_app/core/api/api_client.dart';
import 'package:voclio_app/core/api/api_endpoints.dart';
import 'voice_remote_datasource.dart';
import '../models/voice_recording_model.dart';

class VoiceRemoteDataSourceImpl implements VoiceRemoteDataSource {
  final ApiClient apiClient;

  VoiceRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<VoiceRecordingModel>> getVoiceRecordings() async {
    final response = await apiClient.get(ApiEndpoints.voiceRecordings);

    // DEBUG: View the exact structure of the list
    debugPrint("GET RECORDINGS RESPONSE: ${response.data}");

    // FIX for "Map is not a subtype of List":
    // The server is likely returning pagination data: { "data": { "data": [...] } }
    // or standard: { "data": [...] }
    var rawData = response.data['data'];
    List listData = [];

    if (rawData is List) {
      listData = rawData;
    } else if (rawData is Map && rawData['data'] is List) {
      // Handle Paginated Response
      listData = rawData['data'];
    } else {
      debugPrint(
        "WARNING: unexpected list format. Raw Data type: ${rawData.runtimeType}",
      );
    }

    return listData.map((e) => VoiceRecordingModel.fromJson(e)).toList();
  }

  @override
  Future<VoiceRecordingModel> uploadVoice(File file) async {
    String fileName = file.path.split('/').last;

    final audioFile = await MultipartFile.fromFile(
      file.path,
      filename: fileName,
      contentType: MediaType('audio', 'mp4'),
    );

    FormData formData = FormData.fromMap({
      "audio_file": audioFile, // We confirmed this key is correct
      "language": "ar",
    });

    try {
      final response = await apiClient.post(
        ApiEndpoints.uploadVoice,
        data: formData,
        options: Options(
          headers: {
            "Content-Type": "multipart/form-data",
            "Accept": "application/json",
          },
        ),
      );

      // DEBUG: Print the response to confirm structure
      debugPrint("UPLOAD RESPONSE: ${response.data}");

      // FIX: Drill down into ['data']['recording'] based on your JSON snippet
      final data = response.data['data'];
      final recordingData = data['recording']; // <--- This is the key change

      if (recordingData == null) {
        throw Exception("Upload response missing 'recording' object");
      }

      return VoiceRecordingModel.fromJson(recordingData);
    } on DioException catch (e) {
      debugPrint("UPLOAD ERROR: ${e.response?.data}");
      rethrow;
    }
  }

  @override
  Future<void> deleteVoice(String id) async {
    await apiClient.delete(ApiEndpoints.deleteVoice(id));
  }

  @override
  Future<void> createNoteFromVoice(String id) async {
    await apiClient.post(
      ApiEndpoints.createNoteFromVoice(id),
      data: {
        'title': 'Voice Note ${DateTime.now().toString().split('.')[0]}',
        'tags': [],
      },
    );
  }

  @override
  Future<void> createTasksFromVoice(String id) async {
    await apiClient.post(
      ApiEndpoints.createTasksFromVoice(id),
      data: {'auto_create': true, 'category_id': 1},
    );
  }

  @override
  Future<String> transcribe(String id) async {
    debugPrint("CALLING PROCESS ENDPOINT WITH ID: $id");

    // The body key might be 'recording_id' or just 'id'.
    // 'recording_id' is more likely based on your other APIs.
    final response = await apiClient.post(
      ApiEndpoints.transcribe, // This now points to /voice/process
      data: {'recording_id': id},
    );

    debugPrint("PROCESS RESPONSE: ${response.data}");

    // FIX: Parse the new nested structure
    // The path is response -> data -> transcription
    final responseData = response.data['data'];

    if (responseData != null && responseData['transcription'] != null) {
      return responseData['transcription'] as String;
    }

    // Return empty string if transcription is missing
    return '';
  }

  @override
  Future<VoiceRecordingModel> getVoiceById(String id) async {
    try {
      final response = await apiClient.get(ApiEndpoints.voiceById(id));
      final rawData = response.data;

      if (rawData is Map &&
          rawData['data'] is Map &&
          rawData['data']['recording'] != null) {
        return VoiceRecordingModel.fromJson(rawData['data']['recording']);
      } else if (rawData is Map && rawData['data'] != null) {
        return VoiceRecordingModel.fromJson(rawData['data']);
      }
      return VoiceRecordingModel.fromJson(rawData);
    } catch (e) {
      throw Exception('Failed to fetch voice recording: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> processComplete(File file) async {
    String fileName = file.path.split('/').last;

    final audioFile = await MultipartFile.fromFile(
      file.path,
      filename: fileName,
      contentType: MediaType('audio', 'mp4'),
    );

    FormData formData = FormData.fromMap({
      "audio": audioFile,
      "filename": fileName,
    });

    try {
      final response = await apiClient.post(
        ApiEndpoints.voiceProcessComplete,
        data: formData,
        options: Options(
          headers: {
            "Content-Type": "multipart/form-data",
            "Accept": "application/json",
          },
        ),
      );

      debugPrint("PROCESS COMPLETE RESPONSE: ${response.data}");
      return response.data['data'] ?? response.data;
    } on DioException catch (e) {
      debugPrint("PROCESS COMPLETE ERROR: ${e.response?.data}");
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> previewExtraction(String transcription) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.voicePreviewExtraction,
        data: {'transcription': transcription},
      );
      return response.data['data'] ?? response.data;
    } catch (e) {
      throw Exception('Failed to preview extraction: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> createFromPreview(
    List<Map<String, dynamic>> tasks,
    List<Map<String, dynamic>> notes,
  ) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.voiceCreateFromPreview,
        data: {'tasks': tasks, 'notes': notes},
      );
      return response.data['data'] ?? response.data;
    } catch (e) {
      throw Exception('Failed to create from preview: $e');
    }
  }

  @override
  Future<void> updateTranscription(String voiceId, String transcription) async {
    try {
      await apiClient.put(
        ApiEndpoints.voiceUpdateTranscription,
        data: {'voice_id': voiceId, 'transcription': transcription},
      );
    } catch (e) {
      throw Exception('Failed to update transcription: $e');
    }
  }
}
