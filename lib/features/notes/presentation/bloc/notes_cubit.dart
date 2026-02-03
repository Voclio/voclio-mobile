import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voclio_app/features/notes/domain/entities/note_entity.dart';
import 'package:voclio_app/features/notes/domain/usecases/add_note_use_case.dart';
import 'package:voclio_app/features/notes/domain/usecases/delete_note_use_case.dart';
import 'package:voclio_app/features/notes/domain/usecases/get_all_notes_use_case.dart';
import 'package:voclio_app/features/notes/domain/usecases/get_note_use_case.dart';
import 'package:voclio_app/features/notes/domain/usecases/update_note_use_case.dart';
import 'package:voclio_app/core/domain/usecases/get_tags_use_case.dart';
import 'package:voclio_app/features/notes/presentation/bloc/note_state.dart';

// --- CUBIT ---
class NotesCubit extends Cubit<NotesState> {
  final AddNoteUseCase addNoteUseCase;
  final GetAllNotesUseCase getAllNotesUseCase;
  final GetNoteUseCase getNoteUseCase;
  final UpdateNoteUseCase updateNoteUseCase;
  final DeleteNoteUseCase deleteNoteUseCase;
  final GetTagsUseCase getTagsUseCase;

  NotesCubit({
    required this.addNoteUseCase,
    required this.getAllNotesUseCase,
    required this.getNoteUseCase,
    required this.updateNoteUseCase,
    required this.deleteNoteUseCase,
    required this.getTagsUseCase,
  }) : super(const NotesState());

  Future<void> init() async {
    await fetchTags();
    await getNotes();
  }

  Future<void> fetchTags() async {
    final result = await getTagsUseCase();
    result.fold(
      (failure) => print('Failed to fetch tags: ${failure.message}'),
      (tags) => emit(state.copyWith(availableTags: tags)),
    );
  }

  Future<void> getNotes({String? search}) async {
    emit(state.copyWith(status: NotesStatus.loading));
    final result = await getAllNotesUseCase(search: search);
    // if (isClosed) return;
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
        // Refresh from server to get real ID and formatting
        getNotes();
      },
    );
  }

  Future<void> updateNote(NoteEntity note) async {
    try {
      final index = state.notes.indexWhere((n) => n.id == note.id);
      if (index != -1) {
        final updatedList = List<NoteEntity>.from(state.notes);
        updatedList[index] = note;
        emit(state.copyWith(notes: updatedList));
      }

      final result = await updateNoteUseCase(note);
      result.fold((failure) => getNotes(), (_) {
        getNotes(); // Refresh to sync
      });
    } catch (e) {
      getNotes(); // Revert on error
    }
  }

  Future<void> deleteNote(String id) async {
    // Optimistic update
    final initialNotes = state.notes;
    final updatedList = state.notes.where((n) => n.id != id).toList();
    emit(state.copyWith(notes: updatedList));

    final result = await deleteNoteUseCase(id);
    result.fold(
      (failure) {
        // Revert on failure
        emit(
          state.copyWith(
            notes: initialNotes,
            status: NotesStatus.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (_) {
        // success - refresh from server to be sure
        getNotes();
      },
    );
  }
}
