import 'package:dartz/dartz.dart';
import 'package:voclio_app/core/errors/failures.dart';
import '../repositories/note_repository.dart';

class SummarizeNoteUseCase {
  final NoteRepository _repository;

  SummarizeNoteUseCase(this._repository);

  Future<Either<Failure, String>> call(String noteId) async {
    return _repository.summarizeNote(noteId);
  }
}

class ExtractTasksFromNoteUseCase {
  final NoteRepository _repository;

  ExtractTasksFromNoteUseCase(this._repository);

  Future<Either<Failure, List<String>>> call(
    String noteId, {
    bool autoCreate = false,
  }) async {
    return _repository.extractTasksFromNote(noteId, autoCreate: autoCreate);
  }
}
