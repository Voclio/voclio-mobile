import 'package:voclio_app/features/tasks/domain/entities/note_entity.dart';

abstract class NoteRepository {
  Future<void> createNote(NoteEntity note);
  Future<void> updateNote(String noteId, NoteEntity note);
  Future<void> deleteNote(NoteEntity note);
  Future<NoteEntity?> getNote(String noted);
  Future<List<NoteEntity>> getNotes();
}
