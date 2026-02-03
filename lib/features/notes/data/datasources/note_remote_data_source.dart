import 'package:voclio_app/core/api/api_client.dart';
import 'package:voclio_app/core/api/api_endpoints.dart';
import 'package:voclio_app/features/notes/data/models/note_model.dart';

abstract class NoteRemoteDataSource {
  Future<List<NoteModel>> getNotes({String? search});
  Future<NoteModel> addNote(NoteModel note);
  Future<NoteModel> updateNote(NoteModel note);
  Future<void> deleteNote(String id);
  Future<NoteModel?> getNote(String id);
}

class NoteRemoteDataSourceImpl implements NoteRemoteDataSource {
  final ApiClient apiClient;

  NoteRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<NoteModel>> getNotes({String? search}) async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.notes,
        queryParameters: search != null && search.isNotEmpty
            ? {'search': search}
            : null,
      );
      final rawData = response.data;

      List<dynamic> notesList = [];

      if (rawData is Map) {
        if (rawData['data'] != null) {
          final data = rawData['data'];
          if (data is Map && data['notes'] != null) {
            notesList = data['notes'];
          } else if (data is List) {
            notesList = data;
          } else if (data is Map) {
            // Check if it's a map that might contain notes but isn't a list
            // Or if data itself is the note list but typed as Map (unlikely but safe)
          }
        } else if (rawData['notes'] != null) {
          notesList = rawData['notes'];
        }
      } else if (rawData is List) {
        notesList = rawData;
      }

      return notesList.map((e) => NoteModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to fetch notes: $e');
    }
  }

  @override
  Future<NoteModel> addNote(NoteModel note) async {
    final response = await apiClient.post(
      ApiEndpoints.notes,
      data: note.toJson(),
    );
    final rawData = response.data;

    if (rawData is Map && rawData['data'] is Map && rawData['data']['note'] != null) {
      return NoteModel.fromJson(Map<String, dynamic>.from(rawData['data']['note']));
    } else if (rawData is Map && rawData['data'] != null) {
      return NoteModel.fromJson(Map<String, dynamic>.from(rawData['data']));
    } else if (rawData is Map) {
      return NoteModel.fromJson(Map<String, dynamic>.from(rawData));
    }
    throw Exception('Unexpected response format during addNote');
  }

  @override
  Future<NoteModel> updateNote(NoteModel note) async {
    final response = await apiClient.put(
      ApiEndpoints.noteById(note.id),
      data: note.toJson(),
    );
    final rawData = response.data;

    if (rawData is Map && rawData['data'] is Map && rawData['data']['note'] != null) {
      return NoteModel.fromJson(Map<String, dynamic>.from(rawData['data']['note']));
    } else if (rawData is Map && rawData['data'] != null) {
      return NoteModel.fromJson(Map<String, dynamic>.from(rawData['data']));
    } else if (rawData is Map) {
      return NoteModel.fromJson(Map<String, dynamic>.from(rawData));
    }
    return note; // Fallback to current note if update success but response is weird
  }

  @override
  Future<void> deleteNote(String id) async {
    await apiClient.delete(ApiEndpoints.noteById(id));
  }

  @override
  Future<NoteModel?> getNote(String id) async {
    final response = await apiClient.get(ApiEndpoints.noteById(id));
    final rawData = response.data;
    
    if (rawData is Map && rawData['data'] is Map && rawData['data']['note'] != null) {
      return NoteModel.fromJson(Map<String, dynamic>.from(rawData['data']['note']));
    }
    return NoteModel.fromJson(rawData['data']);
  }
}
