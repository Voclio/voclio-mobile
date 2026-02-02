import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_voice_recordings_usecase.dart';
import '../../domain/usecases/upload_voice_usecase.dart';
import '../../domain/usecases/delete_voice_usecase.dart';
import '../../domain/usecases/create_note_from_voice_usecase.dart';
import '../../domain/usecases/create_tasks_from_voice_usecase.dart';
import '../../domain/usecases/transcribe_voice_usecase.dart';
import 'voice_event.dart';
import 'voice_state.dart';

class VoiceBloc extends Bloc<VoiceEvent, VoiceState> {
  final GetVoiceRecordingsUseCase getVoiceRecordingsUseCase;
  final UploadVoiceUseCase uploadVoiceUseCase;
  final DeleteVoiceUseCase deleteVoiceUseCase;
  final CreateNoteFromVoiceUseCase createNoteFromVoiceUseCase;
  final CreateTasksFromVoiceUseCase createTasksFromVoiceUseCase;
  final TranscribeVoiceUseCase transcribeVoiceUseCase;

  VoiceBloc({
    required this.getVoiceRecordingsUseCase,
    required this.uploadVoiceUseCase,
    required this.deleteVoiceUseCase,
    required this.createNoteFromVoiceUseCase,
    required this.createTasksFromVoiceUseCase,
    required this.transcribeVoiceUseCase,
  }) : super(VoiceInitial()) {
    on<LoadVoiceRecordings>(_onLoadVoiceRecordings);
    on<UploadVoiceFile>(_onUploadVoiceFile);
    on<DeleteVoiceRecording>(_onDeleteVoiceRecording);
    on<CreateNoteFromVoice>(_onCreateNoteFromVoice);
    on<CreateTasksFromVoice>(_onCreateTasksFromVoice);
    on<TranscribeVoice>(_onTranscribeVoice);
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
            // Also refresh the list in the background
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
      add(LoadVoiceRecordings());
    });
  }
}
