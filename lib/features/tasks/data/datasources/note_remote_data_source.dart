import 'package:voclio_app/features/tasks/data/models/note_model.dart';
import 'package:dio/dio.dart';

abstract class NoteRemoteDataSource {
  Future<List<NoteModel>> getNotes();
  Future<NoteModel> addNote(NoteModel note);
  Future<NoteModel> updateNote(NoteModel note);
  Future<void> deleteNote(String id);
}

class NoteRemoteDataSourceImpl implements NoteRemoteDataSource {
  final Dio dio;

  NoteRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<NoteModel>> getNotes() async {
    try {
      final response = await dio.get('/notes');
      return (response.data as List).map((e) => NoteModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception();
    }
  }

  @override
  Future<NoteModel> addNote(NoteModel note) async {
    final response = await dio.post('/notes', data: note.toJson());
    return NoteModel.fromJson(response.data);
  }

  @override
  Future<NoteModel> updateNote(NoteModel note) async {
    final response = await dio.put('/notes/${note.id}', data: note.toJson());
    return NoteModel.fromJson(response.data);
  }

  @override
  Future<void> deleteNote(String id) async {
    await dio.delete('/notes/$id');
  }
}
