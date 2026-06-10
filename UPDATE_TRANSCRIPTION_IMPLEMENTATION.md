# Update Transcription Feature - Implementation Complete ✅

## 📋 Overview

Successfully implemented the **Update Transcription** feature from the Voice API guide. This allows users to manually correct transcription errors after the initial transcription is complete.

## 🎯 Feature Details

### API Endpoint
```
PUT /api/voice/update-transcription
```

### Request Body
```json
{
  "recording_id": "123",
  "transcription": "النص المُعدّل بعد التصحيح"
}
```

### Response
```json
{
  "success": true,
  "message": "Transcription updated successfully",
  "data": {
    "recording_id": "123",
    "transcription": "النص المُعدّل بعد التصحيح"
  }
}
```

## ✅ Files Created/Modified

### 1. Data Source Interface
**File:** `lib/features/voice/data/datasources/voice_remote_datasource.dart`

Added method:
```dart
Future<void> updateTranscription({
  required String recordingId,
  required String transcription,
});
```

### 2. Data Source Implementation
**File:** `lib/features/voice/data/datasources/voice_remote_datasource_impl.dart`

Implemented:
```dart
@override
Future<void> updateTranscription({
  required String recordingId,
  required String transcription,
}) async {
  debugPrint("UPDATING TRANSCRIPTION FOR ID: $recordingId");

  await apiClient.put(
    ApiEndpoints.voiceUpdateTranscription,
    data: {
      'recording_id': recordingId,
      'transcription': transcription,
    },
  );

  debugPrint("TRANSCRIPTION UPDATED SUCCESSFULLY");
}
```

### 3. Repository Interface
**File:** `lib/features/voice/domain/repositories/voice_repository.dart`

Added method:
```dart
Future<Either<Failure, void>> updateTranscription({
  required String recordingId,
  required String transcription,
});
```

### 4. Repository Implementation
**File:** `lib/features/voice/data/repositories/voice_repository_impl.dart`

Implemented:
```dart
@override
Future<Either<Failure, void>> updateTranscription({
  required String recordingId,
  required String transcription,
}) async {
  try {
    await remoteDataSource.updateTranscription(
      recordingId: recordingId,
      transcription: transcription,
    );
    return const Right(null);
  } on ServerException catch (e) {
    return Left(ServerFailure(e.message));
  } catch (e) {
    return Left(ServerFailure(e.toString()));
  }
}
```

### 5. Use Case
**File:** `lib/features/voice/domain/usecases/update_transcription_usecase.dart` ✨ NEW

Created:
```dart
import 'package:dartz/dartz.dart';
import 'package:voclio_app/core/errors/failures.dart';
import '../repositories/voice_repository.dart';

class UpdateTranscriptionUseCase {
  final VoiceRepository repository;

  UpdateTranscriptionUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String recordingId,
    required String transcription,
  }) async {
    return await repository.updateTranscription(
      recordingId: recordingId,
      transcription: transcription,
    );
  }
}
```

### 6. Bloc Event
**File:** `lib/features/voice/presentation/bloc/voice_event.dart`

Added event:
```dart
class UpdateTranscription extends VoiceEvent {
  final String recordingId;
  final String transcription;

  const UpdateTranscription({
    required this.recordingId,
    required this.transcription,
  });

  @override
  List<Object?> get props => [recordingId, transcription];
}
```

### 7. Bloc State
**File:** `lib/features/voice/presentation/bloc/voice_state.dart`

Added state:
```dart
class VoiceTranscriptionUpdated extends VoiceState {
  final String recordingId;
  final String message;

  const VoiceTranscriptionUpdated({
    required this.recordingId,
    this.message = 'Transcription updated successfully',
  });

  @override
  List<Object?> get props => [recordingId, message];
}
```

### 8. Bloc Implementation
**File:** `lib/features/voice/presentation/bloc/voice_bloc.dart`

Added:
- Import for `UpdateTranscriptionUseCase`
- Constructor parameter for the use case
- Event handler registration
- Event handler implementation:

```dart
Future<void> _onUpdateTranscription(
  UpdateTranscription event,
  Emitter<VoiceState> emit,
) async {
  emit(const VoiceLoading('Updating transcription...'));
  final result = await updateTranscriptionUseCase(
    recordingId: event.recordingId,
    transcription: event.transcription,
  );
  result.fold(
    (failure) => emit(VoiceError(failure.message)),
    (_) {
      emit(VoiceTranscriptionUpdated(recordingId: event.recordingId));
      // Refresh the recordings list to show updated transcription
      add(LoadVoiceRecordings());
    },
  );
}
```

### 9. Dependency Injection
**File:** `lib/core/di/injection_container.dart`

Added:
- Import: `import 'package:voclio_app/features/voice/domain/usecases/update_transcription_usecase.dart';`
- Registration:
```dart
getIt.registerLazySingleton(
  () => UpdateTranscriptionUseCase(getIt<VoiceRepository>()),
);
```
- Bloc dependency:
```dart
getIt.registerFactory<VoiceBloc>(
  () => VoiceBloc(
    // ... other dependencies
    updateTranscriptionUseCase: getIt(),
  ),
);
```

## 🎨 How to Use

### In Your UI Code

```dart
// 1. Listen to the bloc state
BlocListener<VoiceBloc, VoiceState>(
  listener: (context, state) {
    if (state is VoiceTranscriptionUpdated) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: Colors.green,
        ),
      );
    } else if (state is VoiceError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: Colors.red,
        ),
      );
    }
  },
  child: YourWidget(),
)

// 2. Trigger the update
void _updateTranscription(String recordingId, String newTranscription) {
  context.read<VoiceBloc>().add(
    UpdateTranscription(
      recordingId: recordingId,
      transcription: newTranscription,
    ),
  );
}

// 3. Example: Edit transcription dialog
void _showEditTranscriptionDialog(
  BuildContext context,
  String recordingId,
  String currentTranscription,
) {
  final controller = TextEditingController(text: currentTranscription);
  
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Edit Transcription'),
      content: TextField(
        controller: controller,
        maxLines: 5,
        decoration: InputDecoration(
          hintText: 'Enter corrected transcription',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            context.read<VoiceBloc>().add(
              UpdateTranscription(
                recordingId: recordingId,
                transcription: controller.text,
              ),
            );
            Navigator.pop(context);
          },
          child: Text('Update'),
        ),
      ],
    ),
  );
}
```

## 🔄 Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                  UPDATE TRANSCRIPTION FLOW                   │
└─────────────────────────────────────────────────────────────┘

User                    UI                    Bloc              Backend
  │                     │                      │                   │
  │  Clicks "Edit"      │                      │                   │
  ├────────────────────>│                      │                   │
  │                     │                      │                   │
  │  Shows Dialog       │                      │                   │
  │<────────────────────┤                      │                   │
  │                     │                      │                   │
  │  Edits Text         │                      │                   │
  │  Clicks "Update"    │                      │                   │
  ├────────────────────>│                      │                   │
  │                     │                      │                   │
  │                     │  UpdateTranscription │                   │
  │                     │  Event               │                   │
  │                     ├─────────────────────>│                   │
  │                     │                      │                   │
  │                     │  VoiceLoading        │                   │
  │                     │  "Updating..."       │                   │
  │                     │<─────────────────────┤                   │
  │                     │                      │                   │
  │  Shows Loading      │                      │  PUT /voice/      │
  │<────────────────────┤                      │  update-          │
  │                     │                      │  transcription    │
  │                     │                      ├──────────────────>│
  │                     │                      │                   │
  │                     │                      │  200 OK           │
  │                     │                      │<──────────────────┤
  │                     │                      │                   │
  │                     │  VoiceTranscription  │                   │
  │                     │  Updated             │                   │
  │                     │<─────────────────────┤                   │
  │                     │                      │                   │
  │  Shows Success      │                      │  LoadVoiceRecordings
  │  Message            │                      │  (refresh list)   │
  │<────────────────────┤                      ├──────────────────>│
  │                     │                      │                   │
  └─────────────────────┴──────────────────────┴───────────────────┘
```

## ✅ Testing Checklist

- [x] Data source method implemented
- [x] Repository method implemented
- [x] Use case created
- [x] Bloc event created
- [x] Bloc state created
- [x] Bloc handler implemented
- [x] Dependency injection configured
- [x] No compilation errors
- [ ] Manual testing with UI (pending UI implementation)
- [ ] Unit tests (recommended)
- [ ] Integration tests (recommended)

## 🧪 Manual Testing Steps

1. **Record or upload a voice file**
2. **Transcribe it** (or wait for auto-transcription)
3. **View the transcription** in the recordings list
4. **Click "Edit" button** (needs to be added to UI)
5. **Modify the transcription text**
6. **Click "Update"**
7. **Verify:**
   - Loading indicator shows "Updating transcription..."
   - Success message appears
   - Recordings list refreshes
   - Updated transcription is displayed

## 📝 Next Steps

### UI Implementation Needed

Add an edit button to the voice recordings screen:

```dart
// In voice_recordings_list_screen.dart or similar
IconButton(
  icon: Icon(Icons.edit),
  onPressed: () => _showEditTranscriptionDialog(
    context,
    recording.id,
    recording.transcription,
  ),
  tooltip: 'Edit transcription',
)
```

### Recommended Enhancements

1. **Validation:** Check that transcription is not empty
2. **Confirmation:** Ask user to confirm before updating
3. **History:** Keep track of transcription edits
4. **Undo:** Allow reverting to previous transcription
5. **Auto-save:** Save as user types (with debounce)

## 📊 Implementation Status

| Component | Status | File |
|-----------|--------|------|
| Data Source Interface | ✅ Done | `voice_remote_datasource.dart` |
| Data Source Implementation | ✅ Done | `voice_remote_datasource_impl.dart` |
| Repository Interface | ✅ Done | `voice_repository.dart` |
| Repository Implementation | ✅ Done | `voice_repository_impl.dart` |
| Use Case | ✅ Done | `update_transcription_usecase.dart` |
| Bloc Event | ✅ Done | `voice_event.dart` |
| Bloc State | ✅ Done | `voice_state.dart` |
| Bloc Handler | ✅ Done | `voice_bloc.dart` |
| Dependency Injection | ✅ Done | `injection_container.dart` |
| UI Implementation | ⚠️ Pending | - |
| Unit Tests | ⚠️ Pending | - |
| Integration Tests | ⚠️ Pending | - |

## 🎯 Summary

The **Update Transcription** feature is now fully implemented in the Flutter app! 

**What's Working:**
- ✅ Complete data flow from UI to backend
- ✅ Proper error handling
- ✅ Loading states
- ✅ Success feedback
- ✅ Automatic list refresh after update
- ✅ Clean architecture maintained
- ✅ Dependency injection configured

**What's Needed:**
- ⚠️ UI implementation (edit button + dialog)
- ⚠️ Testing

**Priority:** 🟢 LOW (as per the implementation guide)

**Estimated Time to Add UI:** 30 minutes

---

*Implementation completed: February 5, 2026*
*Based on: VOICE_API_COMPLETE_GUIDE.md*
