// import 'package:dartz/dartz.dart';
// import 'package:voclio_app/core/errors/failures.dart';
// import 'package:voclio_app/features/notes/data/datasources/mock_data_source.dart';
// import '../../domain/entities/note_entity.dart';
// import '../../domain/repositories/note_repository.dart';

// class FakeNoteRepository implements NoteRepository {
//   @override
//   Future<Either<Failure, List<NoteEntity>>> getNotes() async {
//     // Simulate API delay
//     await Future.delayed(const Duration(milliseconds: 800));
//     return Right(mockNotes);
//   }

//   @override
//   Future<Either<Failure, NoteEntity>> createNote(NoteEntity note) async {
//     await Future.delayed(const Duration(milliseconds: 500));
//     mockNotes.insert(0, note); // Add to local list
//     return Right(note);
//   }

//   @override
//   Future<Either<Failure, void>> updateNote(NoteEntity note) async {
//     await Future.delayed(const Duration(milliseconds: 500));
//     final index = mockNotes.indexWhere((n) => n.id == note.id);
//     if (index != -1) {
//       mockNotes[index] = note;
//       return const Right(null);
//     } else {
//       return const Left(CacheFailure("Note not found"));
//     }
//   }

//   @override
//   Future<Either<Failure, void>> deleteNote(String id) async {
//     await Future.delayed(const Duration(milliseconds: 500));
//     mockNotes.removeWhere((n) => n.id == id);
//     return const Right(null);
//   }

//   @override
//   Future<Either<Failure, NoteEntity?>> getNote(String id) async {
//     await Future.delayed(const Duration(milliseconds: 200));
//     final note = mockNotes.firstWhere(
//       (n) => n.id == id,
//       orElse: () => mockNotes.first,
//     );
//     return Right(note);
//   }
// }
