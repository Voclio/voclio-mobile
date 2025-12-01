// --- STATE ---
import 'package:equatable/equatable.dart';
import 'package:voclio_app/features/notes/domain/entities/note_entity.dart';

enum NotesStatus { initial, loading, success, failure }

class NotesState extends Equatable {
  final NotesStatus status;
  final List<NoteEntity> notes;
  final String errorMessage;

  const NotesState({
    this.status = NotesStatus.initial,
    this.notes = const [],
    this.errorMessage = '',
  });

  NotesState copyWith({
    NotesStatus? status,
    List<NoteEntity>? notes,
    String? errorMessage,
  }) {
    return NotesState(
      status: status ?? this.status,
      notes: notes ?? this.notes,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object> get props => [status, notes, errorMessage];
}
