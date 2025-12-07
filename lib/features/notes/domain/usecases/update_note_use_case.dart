import 'package:dartz/dartz.dart';
import 'package:voclio_app/core/errors/failures.dart';
import 'package:voclio_app/features/notes/domain/entities/note_entity.dart';
import 'package:voclio_app/features/notes/domain/repositories/note_repository.dart';

class UpdateNoteUseCase {
  // ignore: unused_field
  final NoteRepository _noteRepository;

  UpdateNoteUseCase(this._noteRepository);

  Future<Either<Failure, void>> call(NoteEntity note) async {
    return await _noteRepository.updateNote(note);
  }
}
