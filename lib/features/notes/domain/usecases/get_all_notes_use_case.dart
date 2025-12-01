import 'package:dartz/dartz.dart';
import 'package:voclio_app/core/errors/failures.dart';
import 'package:voclio_app/features/notes/domain/entities/note_entity.dart';
import 'package:voclio_app/features/notes/domain/repositories/note_repository.dart';

class GetAllNotesUseCase {
  final NoteRepository repository;

  GetAllNotesUseCase(this.repository);

  Future<Either<Failure, List<NoteEntity>>> call() async {
    return await repository.getNotes();
  }
}
