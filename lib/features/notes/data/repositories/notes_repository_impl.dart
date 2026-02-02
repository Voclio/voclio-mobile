import 'package:dartz/dartz.dart';
import 'package:voclio_app/core/errors/failures.dart';
import 'package:voclio_app/features/notes/data/datasources/note_remote_data_source.dart';
import 'package:voclio_app/features/notes/data/models/note_model.dart';
import 'package:voclio_app/features/notes/domain/entities/note_entity.dart';
import 'package:voclio_app/features/notes/domain/repositories/note_repository.dart';

class NoteRepositoryImpl implements NoteRepository {
  final NoteRemoteDataSource remoteDataSource;

  NoteRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, NoteEntity>> createNote(NoteEntity note) async {
    try {
      final noteModel = NoteModel(
        id: note.id,
        title: note.title,
        content: note.content,
        lastEditDate: note.lastEditDate,
        creationDate: note.creationDate,
        tags: note.tags,
        voiceToTextDuration: note.voiceToTextDuration,
      );
      final result = await remoteDataSource.addNote(noteModel);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteNote(String id) async {
    try {
      await remoteDataSource.deleteNote(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, NoteEntity?>> getNote(String id) async {
    try {
      final result = await remoteDataSource.getNote(id);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<NoteEntity>>> getNotes() async {
    try {
      final result = await remoteDataSource.getNotes();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateNote(NoteEntity note) async {
    try {
      final noteModel = NoteModel(
        id: note.id,
        title: note.title,
        content: note.content,
        lastEditDate: note.lastEditDate,
        creationDate: note.creationDate,
        tags: note.tags,
        voiceToTextDuration: note.voiceToTextDuration,
      );
      await remoteDataSource.updateNote(noteModel);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
