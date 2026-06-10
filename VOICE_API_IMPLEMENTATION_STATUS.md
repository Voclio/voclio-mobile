# Voice API Implementation Status

## 📋 Checklist: API Guide vs Flutter Implementation

Based on `VOICE_API_COMPLETE_GUIDE.md`, here's the status of each endpoint in the Flutter app:

---

## ✅ Implemented Endpoints

### 1. **Upload Recording** ✅
- **API:** `POST /api/voice/upload`
- **Flutter:** `ApiEndpoints.uploadVoice` → `/voice/upload`
- **Data Source:** `uploadVoice(File file)` ✅
- **Use Case:** `UploadVoiceUseCase` ✅
- **Status:** ✅ **IMPLEMENTED**

### 2. **Get All Recordings** ✅
- **API:** `GET /api/voice?page=1&limit=20`
- **Flutter:** `ApiEndpoints.voiceRecordings` → `/voice`
- **Data Source:** `getVoiceRecordings()` ✅
- **Use Case:** `GetVoiceRecordingsUseCase` ✅
- **Status:** ✅ **IMPLEMENTED**

### 3. **Get Recording Details** ✅
- **API:** `GET /api/voice/:id`
- **Flutter:** `ApiEndpoints.voiceById(id)` → `/voice/:id`
- **Status:** ✅ **ENDPOINT DEFINED** (needs use case)

### 4. **Delete Recording** ✅
- **API:** `DELETE /api/voice/:id`
- **Flutter:** `ApiEndpoints.deleteVoice(id)` → `/voice/:id`
- **Data Source:** `deleteVoice(String id)` ✅
- **Use Case:** `DeleteVoiceUseCase` ✅
- **Status:** ✅ **IMPLEMENTED**

### 5. **Transcribe Recording** ✅
- **API:** `POST /api/voice/transcribe`
- **Flutter:** `ApiEndpoints.transcribe` → `/voice/transcribe`
- **Data Source:** `transcribe(String id)` ✅
- **Use Case:** `TranscribeVoiceUseCase` ✅
- **Status:** ✅ **IMPLEMENTED**

### 6. **Create Note from Recording** ✅
- **API:** `POST /api/voice/:id/create-note`
- **Flutter:** `ApiEndpoints.createNoteFromVoice(id)` → `/voice/:id/create-note`
- **Data Source:** `createNoteFromVoice(String id)` ✅
- **Use Case:** `CreateNoteFromVoiceUseCase` ✅
- **Status:** ✅ **IMPLEMENTED**

### 7. **Create Tasks from Recording** ✅
- **API:** `POST /api/voice/:id/create-tasks`
- **Flutter:** `ApiEndpoints.createTasksFromVoice(id)` → `/voice/:id/create-tasks`
- **Data Source:** `createTasksFromVoice(String id)` ✅
- **Use Case:** `CreateTasksFromVoiceUseCase` ✅
- **Status:** ✅ **IMPLEMENTED**

---

## ⚠️ Partially Implemented / Needs Enhancement

### 8. **ONE-CLICK Complete Processing** ⚠️
- **API:** `POST /api/voice/process-complete`
- **Flutter:** `ApiEndpoints.voiceProcessComplete` → `/voice/process-complete`
- **Status:** ⚠️ **ENDPOINT DEFINED** but not implemented in data source
- **Priority:** 🔴 **HIGH** - This is the main feature!
- **Action Required:**
  ```dart
  // Add to VoiceRemoteDataSource
  Future<ProcessCompleteResponse> processComplete({
    required File audioFile,
    String language = 'ar',
    int? categoryId,
    bool autoCreateTasks = true,
    bool autoCreateNotes = true,
  });
  ```

### 9. **Preview Extraction** ⚠️
- **API:** `POST /api/voice/preview-extraction`
- **Flutter:** `ApiEndpoints.voicePreviewExtraction` → `/voice/preview-extraction`
- **Status:** ⚠️ **ENDPOINT DEFINED** but not implemented in data source
- **Priority:** 🟡 **MEDIUM**
- **Action Required:**
  ```dart
  // Add to VoiceRemoteDataSource
  Future<PreviewExtractionResponse> previewExtraction({
    required String recordingId,
    String extractionType = 'both', // 'tasks', 'notes', 'both'
  });
  ```

### 10. **Create from Preview** ⚠️
- **API:** `POST /api/voice/create-from-preview`
- **Flutter:** `ApiEndpoints.voiceCreateFromPreview` → `/voice/create-from-preview`
- **Status:** ⚠️ **ENDPOINT DEFINED** but not implemented in data source
- **Priority:** 🟡 **MEDIUM**
- **Action Required:**
  ```dart
  // Add to VoiceRemoteDataSource
  Future<CreateFromPreviewResponse> createFromPreview({
    required String recordingId,
    required List<TaskPreview> tasks,
    required List<NotePreview> notes,
    int? categoryId,
  });
  ```

### 11. **Update Transcription** ⚠️
- **API:** `PUT /api/voice/update-transcription`
- **Flutter:** `ApiEndpoints.voiceUpdateTranscription` → `/voice/update-transcription`
- **Status:** ⚠️ **ENDPOINT DEFINED** but not implemented in data source
- **Priority:** 🟢 **LOW**
- **Action Required:**
  ```dart
  // Add to VoiceRemoteDataSource
  Future<void> updateTranscription({
    required String recordingId,
    required String transcription,
  });
  ```

---

## 📊 Implementation Summary

| Category | Count | Percentage |
|----------|-------|------------|
| ✅ Fully Implemented | 7 | 64% |
| ⚠️ Partially Implemented | 4 | 36% |
| ❌ Not Implemented | 0 | 0% |
| **Total Endpoints** | **11** | **100%** |

---

## 🎯 Priority Actions Required

### 🔴 HIGH PRIORITY

#### 1. Implement ONE-CLICK Complete Processing
This is the **main feature** of the voice API - everything in one request!

**File:** `lib/features/voice/data/datasources/voice_remote_datasource.dart`

```dart
abstract class VoiceRemoteDataSource {
  // ... existing methods ...
  
  /// ONE-CLICK: Upload, transcribe, extract, and create in one request
  Future<ProcessCompleteResponse> processComplete({
    required File audioFile,
    String language = 'ar',
    int? categoryId,
    bool autoCreateTasks = true,
    bool autoCreateNotes = true,
  });
}
```

**File:** `lib/features/voice/data/datasources/voice_remote_datasource_impl.dart`

```dart
@override
Future<ProcessCompleteResponse> processComplete({
  required File audioFile,
  String language = 'ar',
  int? categoryId,
  bool autoCreateTasks = true,
  bool autoCreateNotes = true,
}) async {
  String fileName = audioFile.path.split('/').last;

  final audioFileMultipart = await MultipartFile.fromFile(
    audioFile.path,
    filename: fileName,
    contentType: MediaType('audio', 'mp4'),
  );

  FormData formData = FormData.fromMap({
    "audio_file": audioFileMultipart,
    "language": language,
    if (categoryId != null) "category_id": categoryId,
    "auto_create_tasks": autoCreateTasks,
    "auto_create_notes": autoCreateNotes,
  });

  final response = await apiClient.post(
    ApiEndpoints.voiceProcessComplete,
    data: formData,
    options: Options(
      headers: {
        "Content-Type": "multipart/form-data",
        "Accept": "application/json",
      },
    ),
  );

  return ProcessCompleteResponse.fromJson(response.data['data']);
}
```

**Create Model:** `lib/features/voice/data/models/process_complete_response_model.dart`

```dart
class ProcessCompleteResponse {
  final int recordingId;
  final String transcription;
  final ExtractedData extracted;
  final CreatedData created;

  ProcessCompleteResponse({
    required this.recordingId,
    required this.transcription,
    required this.extracted,
    required this.created,
  });

  factory ProcessCompleteResponse.fromJson(Map<String, dynamic> json) {
    return ProcessCompleteResponse(
      recordingId: json['recording_id'],
      transcription: json['transcription'],
      extracted: ExtractedData.fromJson(json['extracted']),
      created: CreatedData.fromJson(json['created']),
    );
  }
}

class ExtractedData {
  final List<TaskPreview> tasks;
  final List<NotePreview> notes;

  ExtractedData({required this.tasks, required this.notes});

  factory ExtractedData.fromJson(Map<String, dynamic> json) {
    return ExtractedData(
      tasks: (json['tasks'] as List)
          .map((e) => TaskPreview.fromJson(e))
          .toList(),
      notes: (json['notes'] as List)
          .map((e) => NotePreview.fromJson(e))
          .toList(),
    );
  }
}

class CreatedData {
  final List<TaskEntity> tasks;
  final List<NoteEntity> notes;

  CreatedData({required this.tasks, required this.notes});

  factory CreatedData.fromJson(Map<String, dynamic> json) {
    return CreatedData(
      tasks: (json['tasks'] as List)
          .map((e) => TaskEntity.fromJson(e))
          .toList(),
      notes: (json['notes'] as List)
          .map((e) => NoteEntity.fromJson(e))
          .toList(),
    );
  }
}
```

---

### 🟡 MEDIUM PRIORITY

#### 2. Implement Preview Extraction

**Purpose:** Allow users to review extracted tasks/notes before creating them.

**File:** `lib/features/voice/data/datasources/voice_remote_datasource.dart`

```dart
Future<PreviewExtractionResponse> previewExtraction({
  required String recordingId,
  String extractionType = 'both',
});
```

**Implementation:**

```dart
@override
Future<PreviewExtractionResponse> previewExtraction({
  required String recordingId,
  String extractionType = 'both',
}) async {
  final response = await apiClient.post(
    ApiEndpoints.voicePreviewExtraction,
    data: {
      'recording_id': recordingId,
      'extraction_type': extractionType,
    },
  );

  return PreviewExtractionResponse.fromJson(response.data['data']);
}
```

#### 3. Implement Create from Preview

**Purpose:** Create tasks/notes after user reviews and edits the preview.

```dart
Future<CreateFromPreviewResponse> createFromPreview({
  required String recordingId,
  required List<Map<String, dynamic>> tasks,
  required List<Map<String, dynamic>> notes,
  int? categoryId,
});
```

---

### 🟢 LOW PRIORITY

#### 4. Implement Update Transcription

**Purpose:** Allow users to manually correct transcription errors.

```dart
Future<void> updateTranscription({
  required String recordingId,
  required String transcription,
});
```

---

## 🔧 Additional Enhancements Needed

### 1. **Pagination Support** ⚠️
The API supports pagination (`?page=1&limit=20`), but the Flutter implementation doesn't use it.

**Current:**
```dart
Future<List<VoiceRecordingModel>> getVoiceRecordings();
```

**Should be:**
```dart
Future<PaginatedVoiceRecordings> getVoiceRecordings({
  int page = 1,
  int limit = 20,
});
```

### 2. **Language Selection** ⚠️
The upload method hardcodes `language: "ar"`. Should be configurable.

**Current:**
```dart
FormData formData = FormData.fromMap({
  "audio_file": audioFile,
  "language": "ar", // ← Hardcoded
});
```

**Should be:**
```dart
Future<VoiceRecordingModel> uploadVoice(
  File file, {
  String language = 'ar',
});
```

### 3. **Category Support** ⚠️
The `createTasksFromVoice` method hardcodes `category_id: 1`.

**Current:**
```dart
data: {'auto_create': true, 'category_id': 1} // ← Hardcoded
```

**Should be:**
```dart
Future<void> createTasksFromVoice(
  String id, {
  int? categoryId,
  bool autoCreate = true,
});
```

### 4. **Error Handling** ⚠️
Need better error messages for voice-specific errors:
- Invalid audio format
- File too large
- Transcription failed
- AI extraction failed

### 5. **Loading States** ⚠️
Voice processing can take 15-75 seconds. Need proper loading indicators:
- Uploading...
- Transcribing...
- Extracting tasks...
- Creating items...

---

## 📱 UI/UX Recommendations

### 1. **Voice Recording Screen**
- ✅ Record button
- ✅ Waveform visualization
- ⚠️ Language selector (add)
- ⚠️ Category selector (add)
- ⚠️ Processing progress indicator (add)

### 2. **Voice Recordings List**
- ✅ List of recordings
- ⚠️ Pagination (add)
- ⚠️ Filter by date/status (add)
- ⚠️ Search (add)

### 3. **Preview Screen** (NEW - needs to be created)
- Show transcription
- Show extracted tasks with edit option
- Show extracted notes with edit option
- Confirm/Cancel buttons

### 4. **Processing Feedback**
- Show progress: "Uploading... 30%"
- Show progress: "Transcribing... 60%"
- Show progress: "Extracting tasks... 90%"
- Show success: "Created 3 tasks and 1 note!"

---

## 🧪 Testing Checklist

### Unit Tests Needed
- [ ] Upload voice with different formats
- [ ] Upload voice with different languages
- [ ] Process complete with auto-create enabled
- [ ] Process complete with auto-create disabled
- [ ] Preview extraction for tasks only
- [ ] Preview extraction for notes only
- [ ] Preview extraction for both
- [ ] Create from preview with edited data
- [ ] Update transcription
- [ ] Delete recording
- [ ] Get recordings with pagination

### Integration Tests Needed
- [ ] Full flow: Record → Upload → Transcribe → Extract → Create
- [ ] Preview flow: Upload → Preview → Edit → Create
- [ ] Error handling: Invalid format
- [ ] Error handling: File too large
- [ ] Error handling: Network error

---

## 📝 Documentation Needed

### 1. **User Guide**
- How to record voice
- How to select language
- How to review and edit extracted tasks
- Supported languages and dialects

### 2. **Developer Guide**
- How to add new voice features
- How to handle voice processing states
- How to customize extraction logic

### 3. **API Integration Guide**
- How to test voice APIs
- How to handle errors
- How to optimize performance

---

## 🚀 Recommended Implementation Order

### Phase 1: Core Features (Week 1)
1. ✅ Upload voice
2. ✅ Get recordings
3. ✅ Delete recording
4. ✅ Transcribe
5. ✅ Create tasks from voice
6. ✅ Create note from voice

### Phase 2: ONE-CLICK Feature (Week 2)
1. 🔴 Implement `processComplete` endpoint
2. 🔴 Create response models
3. 🔴 Add use case
4. 🔴 Update UI to use ONE-CLICK
5. 🔴 Add progress indicators

### Phase 3: Preview Feature (Week 3)
1. 🟡 Implement `previewExtraction` endpoint
2. 🟡 Implement `createFromPreview` endpoint
3. 🟡 Create preview screen UI
4. 🟡 Add edit functionality
5. 🟡 Add confirmation flow

### Phase 4: Enhancements (Week 4)
1. 🟢 Add pagination support
2. 🟢 Add language selection
3. 🟢 Add category selection
4. 🟢 Implement update transcription
5. 🟢 Add search and filters

---

## 📊 Current vs Target State

### Current State
```
User Flow:
1. Record voice ✅
2. Upload ✅
3. Transcribe ✅
4. Manually create tasks ✅
5. Manually create notes ✅
```

### Target State (with ONE-CLICK)
```
User Flow:
1. Record voice ✅
2. ONE-CLICK: Upload + Transcribe + Extract + Create ⚠️
3. Done! ✅

OR (with Preview):
1. Record voice ✅
2. Upload + Transcribe + Extract ⚠️
3. Review and edit preview ⚠️
4. Confirm and create ⚠️
5. Done! ✅
```

---

## 🎯 Success Metrics

### Performance
- Upload time: < 2 seconds
- Transcription time: < 60 seconds
- Extraction time: < 15 seconds
- Total ONE-CLICK time: < 75 seconds

### Accuracy
- Transcription accuracy: > 90%
- Task extraction accuracy: > 85%
- Date/time parsing accuracy: > 90%
- Priority detection accuracy: > 80%

### User Experience
- User can create tasks in < 2 minutes
- User can review and edit before creating
- Clear progress indicators
- Helpful error messages

---

## 📞 Next Steps

1. **Review this document** with the team
2. **Prioritize** which features to implement first
3. **Assign tasks** to developers
4. **Set timeline** for each phase
5. **Start with Phase 2** (ONE-CLICK feature) as it's the most important

---

## 🙏 Summary

**Good News:** 
- ✅ 64% of endpoints are already implemented
- ✅ Core infrastructure is in place
- ✅ Basic voice features work

**Action Required:**
- 🔴 Implement ONE-CLICK complete processing (HIGH PRIORITY)
- 🟡 Implement preview extraction workflow (MEDIUM PRIORITY)
- 🟢 Add enhancements like pagination, language selection (LOW PRIORITY)

**Estimated Time:**
- Phase 1: ✅ Complete
- Phase 2: 1 week (ONE-CLICK)
- Phase 3: 1 week (Preview)
- Phase 4: 1 week (Enhancements)
- **Total: 3 weeks** to complete all features

---

*Last updated: February 5, 2026*
*Based on: VOICE_API_COMPLETE_GUIDE.md*
