import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_voice_recordings_usecase.dart';
import '../../domain/usecases/upload_voice_usecase.dart';
import '../../domain/usecases/delete_voice_usecase.dart';
import '../../domain/usecases/create_note_from_voice_usecase.dart';
import '../../domain/usecases/create_tasks_from_voice_usecase.dart';
import '../../domain/usecases/transcribe_voice_usecase.dart';
import '../../domain/usecases/preview_extraction_usecase.dart';
import '../../domain/usecases/create_from_preview_usecase.dart';
import 'package:get_it/get_it.dart';
import '../../../tasks/presentation/bloc/tasks_cubit.dart';
import '../../../notes/presentation/bloc/notes_cubit.dart';
import 'voice_event.dart';
import 'voice_state.dart';

class VoiceBloc extends Bloc<VoiceEvent, VoiceState> {
  final GetVoiceRecordingsUseCase getVoiceRecordingsUseCase;
  final UploadVoiceUseCase uploadVoiceUseCase;
  final DeleteVoiceUseCase deleteVoiceUseCase;
  final CreateNoteFromVoiceUseCase createNoteFromVoiceUseCase;
  final CreateTasksFromVoiceUseCase createTasksFromVoiceUseCase;
  final TranscribeVoiceUseCase transcribeVoiceUseCase;
  final PreviewExtractionUseCase previewExtractionUseCase;
  final CreateFromPreviewUseCase createFromPreviewUseCase;

  VoiceBloc({
    required this.getVoiceRecordingsUseCase,
    required this.uploadVoiceUseCase,
    required this.deleteVoiceUseCase,
    required this.createNoteFromVoiceUseCase,
    required this.createTasksFromVoiceUseCase,
    required this.transcribeVoiceUseCase,
    required this.previewExtractionUseCase,
    required this.createFromPreviewUseCase,
  }) : super(VoiceInitial()) {
    on<LoadVoiceRecordings>(_onLoadVoiceRecordings);
    on<UploadVoiceFile>(_onUploadVoiceFile);
    on<DeleteVoiceRecording>(_onDeleteVoiceRecording);
    on<CreateNoteFromVoice>(_onCreateNoteFromVoice);
    on<CreateTasksFromVoice>(_onCreateTasksFromVoice);
    on<TranscribeVoice>(_onTranscribeVoice);
    on<PreviewExtractionEvent>(_onPreviewExtraction);
    on<UpdateExtractedTask>(_onUpdateExtractedTask);
    on<UpdateExtractedNote>(_onUpdateExtractedNote);
    on<ToggleTaskSelection>(_onToggleTaskSelection);
    on<ToggleNoteSelection>(_onToggleNoteSelection);
    on<CreateFromPreviewEvent>(_onCreateFromPreview);
    on<ClearExtraction>(_onClearExtraction);
  }

  Future<void> _onLoadVoiceRecordings(
    LoadVoiceRecordings event,
    Emitter<VoiceState> emit,
  ) async {
    emit(const VoiceLoading('Loading recordings...'));
    final result = await getVoiceRecordingsUseCase();
    result.fold(
      (failure) => emit(VoiceError(failure.message)),
      (recordings) => emit(VoiceLoaded(recordings)),
    );
  }

  Future<void> _onUploadVoiceFile(
    UploadVoiceFile event,
    Emitter<VoiceState> emit,
  ) async {
    // 1. Start loading state
    emit(const VoiceLoading('Uploading audio...'));

    // 2. Upload the file
    final uploadResult = await uploadVoiceUseCase(event.file);

    await uploadResult.fold(
      // If upload fails, emit an error
      (failure) async => emit(VoiceError(failure.message)),

      // If upload succeeds, immediately transcribe
      (recording) async {
        // 3. Change state to show 'Transcribing...'
        emit(const VoiceLoading('Transcribing...'));

        // 4. Call the transcribe use case directly
        final transcribeResult = await transcribeVoiceUseCase(recording.id);

        transcribeResult.fold(
          // If transcription fails, emit an error
          (failure) => emit(VoiceError(failure.message)),

          // If transcription succeeds, emit the final success state!
          (transcriptionText) {
            emit(VoiceTranscriptionLoaded(transcriptionText, recording.id));
          },
        );
      },
    );
  }

  Future<void> _onTranscribeVoice(
    TranscribeVoice event,
    Emitter<VoiceState> emit,
  ) async {
    emit(const VoiceLoading('Transcribing...'));
    final result = await transcribeVoiceUseCase(event.id);
    result.fold(
      (failure) => emit(VoiceError(failure.message)),
      (transcription) =>
          emit(VoiceTranscriptionLoaded(transcription, event.id)),
    );
  }

  Future<void> _onDeleteVoiceRecording(
    DeleteVoiceRecording event,
    Emitter<VoiceState> emit,
  ) async {
    emit(const VoiceLoading('Deleting...'));
    final result = await deleteVoiceUseCase(event.id);
    result.fold((failure) => emit(VoiceError(failure.message)), (_) {
      emit(const VoiceOperationSuccess('Recording deleted'));
      add(LoadVoiceRecordings());
    });
  }

  Future<void> _onCreateNoteFromVoice(
    CreateNoteFromVoice event,
    Emitter<VoiceState> emit,
  ) async {
    emit(const VoiceLoading('Creating note...'));
    final result = await createNoteFromVoiceUseCase(event.id);
    result.fold((failure) => emit(VoiceError(failure.message)), (_) {
      emit(const VoiceOperationSuccess('Note created from voice'));
      add(LoadVoiceRecordings());
    });
  }

  Future<void> _onCreateTasksFromVoice(
    CreateTasksFromVoice event,
    Emitter<VoiceState> emit,
  ) async {
    emit(const VoiceLoading('Creating tasks...'));
    final result = await createTasksFromVoiceUseCase(event.id);
    result.fold((failure) => emit(VoiceError(failure.message)), (_) {
      emit(const VoiceOperationSuccess('Tasks created from voice'));
      // Trigger tasks refresh automatically
      GetIt.I<TasksCubit>().getTasks();
      add(LoadVoiceRecordings());
    });
  }

  Future<void> _onPreviewExtraction(
    PreviewExtractionEvent event,
    Emitter<VoiceState> emit,
  ) async {
    final currentState = state;
    String recordingId = '';
    
    if (currentState is VoiceTranscriptionLoaded) {
      recordingId = currentState.recordingId;
    } else if (currentState is VoiceExtractionLoaded) {
      recordingId = currentState.recordingId;
    }

    emit(VoiceExtractionLoading(
      transcription: event.transcription,
      recordingId: recordingId,
      message: '✨ AI is analyzing your voice...',
    ));

    final result = await previewExtractionUseCase(event.transcription);
    
    result.fold(
      (failure) => emit(VoiceError(failure.message)),
      (extraction) => emit(VoiceExtractionLoaded(
        transcription: event.transcription,
        recordingId: recordingId,
        extraction: extraction,
      )),
    );
  }

  void _onUpdateExtractedTask(
    UpdateExtractedTask event,
    Emitter<VoiceState> emit,
  ) {
    final currentState = state;
    if (currentState is VoiceExtractionLoaded) {
      final updatedTasks = currentState.extraction.tasks.map((task) {
        return task.id == event.task.id ? event.task : task;
      }).toList();

      emit(currentState.copyWith(
        extraction: currentState.extraction.copyWith(tasks: updatedTasks),
      ));
    }
  }

  void _onUpdateExtractedNote(
    UpdateExtractedNote event,
    Emitter<VoiceState> emit,
  ) {
    final currentState = state;
    if (currentState is VoiceExtractionLoaded) {
      final updatedNotes = currentState.extraction.notes.map((note) {
        return note.id == event.note.id ? event.note : note;
      }).toList();

      emit(currentState.copyWith(
        extraction: currentState.extraction.copyWith(notes: updatedNotes),
      ));
    }
  }

  void _onToggleTaskSelection(
    ToggleTaskSelection event,
    Emitter<VoiceState> emit,
  ) {
    final currentState = state;
    if (currentState is VoiceExtractionLoaded) {
      final updatedTasks = currentState.extraction.tasks.map((task) {
        return task.id == event.taskId
            ? task.copyWith(isSelected: !task.isSelected)
            : task;
      }).toList();

      emit(currentState.copyWith(
        extraction: currentState.extraction.copyWith(tasks: updatedTasks),
      ));
    }
  }

  void _onToggleNoteSelection(
    ToggleNoteSelection event,
    Emitter<VoiceState> emit,
  ) {
    final currentState = state;
    if (currentState is VoiceExtractionLoaded) {
      final updatedNotes = currentState.extraction.notes.map((note) {
        return note.id == event.noteId
            ? note.copyWith(isSelected: !note.isSelected)
            : note;
      }).toList();

      emit(currentState.copyWith(
        extraction: currentState.extraction.copyWith(notes: updatedNotes),
      ));
    }
  }

  Future<void> _onCreateFromPreview(
    CreateFromPreviewEvent event,
    Emitter<VoiceState> emit,
  ) async {
    emit(const VoiceCreatingFromPreview('Creating your items...'));

    final result = await createFromPreviewUseCase(
      tasks: event.tasks,
      notes: event.notes,
    );

    result.fold(
      (failure) => emit(VoiceError(failure.message)),
      (_) {
        final selectedTasks = event.tasks.where((t) => t.isSelected).length;
        final selectedNotes = event.notes.where((n) => n.isSelected).length;
        
        String message = '✅ Created ';
        if (selectedTasks > 0) message += '$selectedTasks task${selectedTasks > 1 ? 's' : ''}';
        if (selectedTasks > 0 && selectedNotes > 0) message += ' and ';
        if (selectedNotes > 0) message += '$selectedNotes note${selectedNotes > 1 ? 's' : ''}';
        
        emit(VoiceOperationSuccess(message));
        
        // Refresh tasks and notes
        try {
          GetIt.I<TasksCubit>().getTasks();
        } catch (_) {}
        try {
          GetIt.I<NotesCubit>().getNotes();
        } catch (_) {}
        
        add(LoadVoiceRecordings());
      },
    );
  }

  void _onClearExtraction(
    ClearExtraction event,
    Emitter<VoiceState> emit,
  ) {
    emit(VoiceInitial());
  }
}

