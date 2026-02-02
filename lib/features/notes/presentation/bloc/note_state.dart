// --- STATE ---
import 'package:equatable/equatable.dart';
import 'package:voclio_app/features/notes/domain/entities/note_entity.dart';
import 'package:voclio_app/core/domain/entities/tag_entity.dart';

enum NotesStatus { initial, loading, success, failure }

class NotesState extends Equatable {
  final NotesStatus status;
  final List<NoteEntity> notes;
  final String errorMessage;
  final List<TagEntity> availableTags;

  const NotesState({
    this.status = NotesStatus.initial,
    this.notes = const [],
    this.errorMessage = '',
    this.availableTags = const [],
  });

  NotesState copyWith({
    NotesStatus? status,
    List<NoteEntity>? notes,
    String? errorMessage,
    List<TagEntity>? availableTags,
  }) {
    return NotesState(
      status: status ?? this.status,
      notes: notes ?? this.notes,
      errorMessage: errorMessage ?? this.errorMessage,
      availableTags: availableTags ?? this.availableTags,
    );
  }

  @override
  List<Object> get props => [status, notes, errorMessage, availableTags];
}
