import 'package:voclio_app/core/api/api_client.dart';
import 'package:voclio_app/core/api/api_endpoints.dart';
import 'package:voclio_app/features/notes/data/models/note_model.dart';

abstract class NoteRemoteDataSource {
  Future<List<NoteModel>> getNotes();
  Future<NoteModel> addNote(NoteModel note);
  Future<NoteModel> updateNote(NoteModel note);
  Future<void> deleteNote(String id);
  Future<NoteModel?> getNote(String id);
}

class NoteRemoteDataSourceImpl implements NoteRemoteDataSource {
  final ApiClient apiClient;

  NoteRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<NoteModel>> getNotes() async {
    try {
      final response = await apiClient.get(ApiEndpoints.notes);
      final List<dynamic> notesData = response.data['data']['notes'] ?? [];
      return notesData.map((e) => NoteModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to fetch notes: $e');
    }
  }

  @override
  Future<NoteModel> addNote(NoteModel note) async {
    final response = await apiClient.post(ApiEndpoints.notes, data: note.toJson());
    return NoteModel.fromJson(response.data['data']);
  }

  @override
  Future<NoteModel> updateNote(NoteModel note) async {
    final response = await apiClient.put(
      ApiEndpoints.noteById(note.id),
      data: note.toJson(),
    );
    return NoteModel.fromJson(response.data['data']);
  }

  @override
  Future<void> deleteNote(String id) async {
    await apiClient.delete(ApiEndpoints.noteById(id));
  }

  @override
  Future<NoteModel?> getNote(String id) async {
    final response = await apiClient.get(ApiEndpoints.noteById(id));
    return NoteModel.fromJson(response.data['data']);
  }
}
