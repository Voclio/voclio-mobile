import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voclio_app/features/calendar/presentation/bloc/calendar_cubit.dart';
import 'package:voclio_app/features/tasks/presentation/bloc/tasks_cubit.dart';
import '../../domain/usecases/get_voice_recordings_usecase.dart';
import '../../domain/usecases/upload_voice_usecase.dart';
import '../../domain/usecases/delete_voice_usecase.dart';
import '../../domain/usecases/create_note_from_voice_usecase.dart';
import '../../domain/usecases/create_tasks_from_voice_usecase.dart';
import '../../domain/usecases/transcribe_voice_usecase.dart';
import '../../domain/usecases/update_transcription_usecase.dart';
import 'package:get_it/get_it.dart';
import 'voice_event.dart';
import 'voice_state.dart';

class VoiceBloc extends Bloc<VoiceEvent, VoiceState> {
  final GetVoiceRecordingsUseCase getVoiceRecordingsUseCase;
  final UploadVoiceUseCase uploadVoiceUseCase;
  final DeleteVoiceUseCase deleteVoiceUseCase;
  final CreateNoteFromVoiceUseCase createNoteFromVoiceUseCase;
  final CreateTasksFromVoiceUseCase createTasksFromVoiceUseCase;
  final TranscribeVoiceUseCase transcribeVoiceUseCase;
  final UpdateTranscriptionUseCase updateTranscriptionUseCase;

  VoiceBloc({
    required this.getVoiceRecordingsUseCase,
    required this.uploadVoiceUseCase,
    required this.deleteVoiceUseCase,
    required this.createNoteFromVoiceUseCase,
    required this.createTasksFromVoiceUseCase,
    required this.transcribeVoiceUseCase,
    required this.updateTranscriptionUseCase,
  }) : super(VoiceInitial()) {
    on<LoadVoiceRecordings>(_onLoadVoiceRecordings);
    on<UploadVoiceFile>(_onUploadVoiceFile);
    on<DeleteVoiceRecording>(_onDeleteVoiceRecording);
    on<CreateNoteFromVoice>(_onCreateNoteFromVoice);
    on<CreateTasksFromVoice>(_onCreateTasksFromVoice);
    on<TranscribeVoice>(_onTranscribeVoice);
    on<UpdateTranscription>(_onUpdateTranscription);
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
        final existingTranscription = recording.transcription?.trim();
        if (existingTranscription != null && existingTranscription.isNotEmpty) {
          emit(VoiceTranscriptionLoaded(existingTranscription, recording.id));
          add(LoadVoiceRecordings());
          return;
        }

        emit(const VoiceLoading('Transcribing...'));

        final transcribeResult = await transcribeVoiceUseCase(recording.id);

        transcribeResult.fold(
          (failure) => emit(VoiceError(failure.message)),
          (transcriptionText) {
            if (transcriptionText.trim().isEmpty) {
              emit(const VoiceError(
                'No speech detected. Try speaking louder or closer to the mic.',
              ));
              return;
            }
            emit(VoiceTranscriptionLoaded(transcriptionText, recording.id));
            add(LoadVoiceRecordings());
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
    final result = await createNoteFromVoiceUseCase(
      event.id,
      transcription: event.transcription,
    );
    result.fold((failure) => emit(VoiceError(failure.message)), (_) {
      emit(const VoiceOperationSuccess(
        'Note saved',
        destination: VoiceSuccessDestination.notes,
      ));
      add(LoadVoiceRecordings());
    });
  }

  Future<void> _onCreateTasksFromVoice(
    CreateTasksFromVoice event,
    Emitter<VoiceState> emit,
  ) async {
    emit(const VoiceLoading('Creating tasks...'));
    final result = await createTasksFromVoiceUseCase(
      event.id,
      transcription: event.transcription,
    );
    result.fold((failure) => emit(VoiceError(failure.message)), (dueDate) {
      final focusDate = dueDate ?? DateTime.now();
      GetIt.I<CalendarCubit>().loadMonth(
        focusDate.year,
        focusDate.month,
        force: true,
      );
      GetIt.I<TasksCubit>().getTasks();
      emit(
        VoiceOperationSuccess(
          'Task added to your calendar',
          destination: VoiceSuccessDestination.calendar,
          calendarFocusDate: focusDate,
        ),
      );
      add(LoadVoiceRecordings());
    });
  }

  Future<void> _onUpdateTranscription(
    UpdateTranscription event,
    Emitter<VoiceState> emit,
  ) async {
    emit(const VoiceLoading('Updating transcription...'));
    final result = await updateTranscriptionUseCase(
      recordingId: event.recordingId,
      transcription: event.transcription,
    );
    result.fold((failure) => emit(VoiceError(failure.message)), (_) {
      emit(VoiceTranscriptionUpdated(recordingId: event.recordingId));
      // Refresh the recordings list to show updated transcription
      add(LoadVoiceRecordings());
    });
  }
}
