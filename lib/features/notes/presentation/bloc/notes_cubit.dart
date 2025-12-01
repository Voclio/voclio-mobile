import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:voclio_app/features/notes/domain/entities/note_entity.dart';
import 'package:voclio_app/features/notes/domain/usecases/add_note_use_case.dart';
import 'package:voclio_app/features/notes/domain/usecases/delete_note_use_case.dart';
import 'package:voclio_app/features/notes/domain/usecases/get_all_notes_use_case.dart';
import 'package:voclio_app/features/notes/domain/usecases/get_note_use_case.dart';
import 'package:voclio_app/features/notes/domain/usecases/update_note_use_case.dart';
import 'package:voclio_app/features/notes/presentation/bloc/note_state.dart';

// --- CUBIT ---
class NotesCubit extends Cubit<NotesState> {
  final AddNoteUseCase addNoteUseCase;
  final GetAllNotesUseCase getAllNotesUseCase;
  final GetNoteUseCase getNoteUseCase;
  final UpdateNoteUseCase updateNoteUseCase;
  final DeleteNoteUseCase deleteNoteUseCase;

  NotesCubit({
    required this.addNoteUseCase,
    required this.getAllNotesUseCase,
    required this.getNoteUseCase,
    required this.updateNoteUseCase,
    required this.deleteNoteUseCase,
  }) : super(const NotesState());

  Future<void> getNotes() async {
    emit(state.copyWith(status: NotesStatus.loading));
    final result = await getAllNotesUseCase();
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: NotesStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (notes) =>
          emit(state.copyWith(status: NotesStatus.success, notes: notes)),
    );
  }

  Future<void> addNote(NoteEntity note) async {
    final result = await addNoteUseCase(note);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: NotesStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (newNote) {
        final updatedList = List<NoteEntity>.from(state.notes)
          ..insert(0, newNote); // Add to top
        emit(state.copyWith(status: NotesStatus.success, notes: updatedList));
      },
    );
  }

  Future<void> updateNote(NoteEntity note) async {
    // Optimistic Update
    final index = state.notes.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      final updatedList = List<NoteEntity>.from(state.notes);
      updatedList[index] = note;
      emit(state.copyWith(notes: updatedList));
    }

    final result = await updateNoteUseCase(note);
    result.fold((failure) {
      // Revert or error
      getNotes();
    }, (_) {});
  }

  Future<void> deleteNote(String id) async {
    final updatedList = state.notes.where((n) => n.id != id).toList();
    emit(state.copyWith(notes: updatedList));

    final result = await deleteNoteUseCase(id);
    result.fold(
      (failure) => getNotes(), // Revert
      (_) {},
    );
  }
}
