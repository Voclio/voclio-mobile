# 🎤 Voclio Voice APIs - Complete Guide

## 📚 Table of Contents
1. [Overview](#overview)
2. [Authentication](#authentication)
3. [API Endpoints](#api-endpoints)
4. [Request/Response Examples](#examples)
5. [Error Handling](#error-handling)
6. [Best Practices](#best-practices)

---

## 🌟 Overview

Voclio Voice APIs allow you to convert voice recordings to text and automatically extract tasks and notes using AI.

### Key Features
- ✅ Multi-language transcription (13 languages)
- ✅ Arabic dialect support (Egyptian, Saudi, Levantine, Moroccan)
- ✅ Smart task extraction with subtasks
- ✅ Automatic date/time parsing
- ✅ Priority detection
- ✅ Note extraction with auto-tagging
- ✅ ONE-CLICK processing

### Supported Languages
`ar` (Arabic), `en` (English), `fr` (French), `es` (Spanish), `de` (German), `it` (Italian), `pt` (Portuguese), `ru` (Russian), `ja` (Japanese), `ko` (Korean), `zh` (Chinese), `hi` (Hindi), `tr` (Turkish)

---

## 🔐 Authentication

All endpoints require JWT authentication:

```http
Authorization: Bearer YOUR_JWT_TOKEN
```

Get your token from the login endpoint:
```bash
POST /api/auth/login
```

---

## 📡 API Endpoints

### 1. ONE-CLICK Complete Processing ⚡
**The easiest way - everything in one request!**

```http
POST /api/voice/process-complete
Content-Type: multipart/form-data
```

**Parameters:**
- `audio_file` (required): Audio file (MP3, WAV, M4A, OGG, WEBM)
- `language` (optional): Language code (default: "ar")
- `category_id` (optional): Category ID for tasks
- `auto_create_tasks` (optional): Auto-create tasks (default: true)
- `auto_create_notes` (optional): Auto-create notes (default: true)

**Response:**
```json
{
  "success": true,
  "message": "Voice processed successfully",
  "data": {
    "recording_id": 123,
    "transcription": "عايز أشتري لبن وخبز بكرة الصبح",
    "extracted": {
      "tasks": [...],
      "notes": [...]
    },
    "created": {
      "tasks": [...],
      "notes": [...]
    }
  }
}
```


---

### 2. Upload Recording

```http
POST /api/voice/upload
Content-Type: multipart/form-data
```

**Parameters:**
- `audio_file` (required): Audio file
- `title` (optional): Recording title

**Response:**
```json
{
  "success": true,
  "message": "Recording uploaded successfully",
  "data": {
    "recording": {
      "recording_id": 123,
      "file_size": 1024000,
      "format": "audio/mpeg",
      "created_at": "2026-02-05T10:00:00Z"
    }
  }
}
```

---

### 3. Transcribe Recording

```http
POST /api/voice/transcribe
Content-Type: application/json
```

**Request Body:**
```json
{
  "recording_id": 123,
  "language": "ar"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Transcription completed successfully",
  "data": {
    "recording_id": 123,
    "transcription": "عايز أشتري لبن وخبز بكرة الصبح",
    "language": "ar"
  }
}
```

---

### 4. Preview Extraction

```http
POST /api/voice/preview-extraction
Content-Type: application/json
```

**Request Body:**
```json
{
  "recording_id": 123,
  "extraction_type": "both"
}
```

**extraction_type options:**
- `"tasks"` - Extract only tasks
- `"notes"` - Extract only notes
- `"both"` - Extract both (default)

**Response:**
```json
{
  "success": true,
  "data": {
    "recording_id": 123,
    "transcription": "عايز أشتري لبن وخبز بكرة",
    "preview": {
      "tasks": [
        {
          "title": "شراء مستلزمات",
          "description": "شراء لبن وخبز",
          "priority": "medium",
          "due_date": "2026-02-06T09:00:00",
          "subtasks": [
            {"title": "شراء لبن"},
            {"title": "شراء خبز"}
          ]
        }
      ],
      "notes": []
    }
  }
}
```

---

### 5. Create from Preview

```http
POST /api/voice/create-from-preview
Content-Type: application/json
```

**Request Body:**
```json
{
  "recording_id": 123,
  "tasks": [
    {
      "title": "شراء مستلزمات",
      "description": "شراء لبن وخبز",
      "priority": "medium",
      "due_date": "2026-02-06T09:00:00",
      "subtasks": [
        {"title": "شراء لبن"},
        {"title": "شراء خبز"}
      ]
    }
  ],
  "notes": [],
  "category_id": 1
}
```

**Response:**
```json
{
  "success": true,
  "message": "Items created successfully",
  "data": {
    "recording_id": 123,
    "created": {
      "tasks": [
        {
          "task_id": 456,
          "title": "شراء مستلزمات",
          "subtasks": [...]
        }
      ],
      "notes": []
    }
  }
}
```

---

### 6. Update Transcription

```http
PUT /api/voice/update-transcription
Content-Type: application/json
```

**Request Body:**
```json
{
  "recording_id": 123,
  "transcription": "النص المُعدّل بعد التصحيح"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Transcription updated successfully",
  "data": {
    "recording_id": 123,
    "transcription": "النص المُعدّل بعد التصحيح"
  }
}
```

---

### 7. Create Note from Recording

```http
POST /api/voice/:id/create-note
Content-Type: application/json
```

**Request Body:**
```json
{
  "title": "ملاحظة صوتية",
  "tags": [1, 2, 3]
}
```

**Response:**
```json
{
  "success": true,
  "message": "Note created from voice recording successfully",
  "data": {
    "note": {
      "note_id": 789,
      "title": "ملاحظة صوتية",
      "content": "...",
      "tags": [...]
    },
    "recording_id": 123
  }
}
```

---

### 8. Create Tasks from Recording

```http
POST /api/voice/:id/create-tasks
Content-Type: application/json
```

**Request Body:**
```json
{
  "auto_create": true,
  "category_id": 1
}
```

**Response:**
```json
{
  "success": true,
  "message": "Tasks created from voice recording successfully",
  "data": {
    "recording_id": 123,
    "tasks": [...],
    "count": 3
  }
}
```

---

### 9. Get All Recordings

```http
GET /api/voice?page=1&limit=20
```

**Query Parameters:**
- `page` (optional): Page number (default: 1)
- `limit` (optional): Items per page (default: 20)

**Response:**
```json
{
  "success": true,
  "data": {
    "recordings": [
      {
        "recording_id": 123,
        "file_size": 1024000,
        "format": "audio/mpeg",
        "transcription_text": "...",
        "created_at": "2026-02-05T10:00:00Z"
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20
    }
  }
}
```

---

### 10. Get Recording Details

```http
GET /api/voice/:id
```

**Response:**
```json
{
  "success": true,
  "data": {
    "recording": {
      "recording_id": 123,
      "file_size": 1024000,
      "duration": 120,
      "format": "audio/mpeg",
      "transcription": "...",
      "created_at": "2026-02-05T10:00:00Z",
      "transcribed_at": "2026-02-05T10:01:00Z"
    }
  }
}
```

---

### 11. Delete Recording

```http
DELETE /api/voice/:id
```

**Response:**
```json
{
  "success": true,
  "message": "Recording deleted successfully"
}
```


---

## 💡 Request/Response Examples

### Example 1: Simple Task

**Voice Input:**
> "عايز أشتري لبن بكرة"

**cURL:**
```bash
curl -X POST http://localhost:3000/api/voice/process-complete \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -F "audio_file=@recording.mp3" \
  -F "language=ar"
```

**Response:**
```json
{
  "success": true,
  "data": {
    "extracted": {
      "tasks": [
        {
          "title": "شراء لبن",
          "priority": "medium",
          "due_date": "2026-02-06T09:00:00"
        }
      ]
    }
  }
}
```

---

### Example 2: Task with List

**Voice Input:**
> "محتاج أشتري لبن وخبز وجبنة وبيض"

**JavaScript:**
```javascript
const formData = new FormData();
formData.append('audio_file', audioFile);
formData.append('language', 'ar');
formData.append('auto_create_tasks', 'true');

const response = await fetch('/api/voice/process-complete', {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${token}`
  },
  body: formData
});

const result = await response.json();
```

**Response:**
```json
{
  "success": true,
  "data": {
    "extracted": {
      "tasks": [
        {
          "title": "شراء مستلزمات",
          "priority": "medium",
          "subtasks": [
            {"title": "شراء لبن"},
            {"title": "شراء خبز"},
            {"title": "شراء جبنة"},
            {"title": "شراء بيض"}
          ]
        }
      ]
    }
  }
}
```

---

### Example 3: Urgent Task with Time

**Voice Input:**
> "مهم جداً أتصل بالدكتور الساعة 3 العصر"

**Python:**
```python
import requests

url = "http://localhost:3000/api/voice/process-complete"
headers = {"Authorization": f"Bearer {token}"}
files = {"audio_file": open("recording.mp3", "rb")}
data = {"language": "ar"}

response = requests.post(url, headers=headers, files=files, data=data)
result = response.json()
```

**Response:**
```json
{
  "success": true,
  "data": {
    "extracted": {
      "tasks": [
        {
          "title": "الاتصال بالدكتور",
          "priority": "high",
          "due_date": "2026-02-05T15:00:00"
        }
      ]
    }
  }
}
```

---

### Example 4: Tasks and Notes Together

**Voice Input:**
> "محتاج أجهز العرض التقديمي للاجتماع يوم الأحد. نوت: لازم أركز على الأرقام والإحصائيات"

**Response:**
```json
{
  "success": true,
  "data": {
    "extracted": {
      "tasks": [
        {
          "title": "تجهيز العرض التقديمي",
          "priority": "high",
          "due_date": "2026-02-09"
        }
      ],
      "notes": [
        {
          "title": "ملاحظة عن العرض التقديمي",
          "content": "لازم أركز على الأرقام والإحصائيات",
          "tags": ["عرض_تقديمي", "اجتماع", "ملاحظة"]
        }
      ]
    }
  }
}
```

---

### Example 5: Preview Before Creating

**Step 1: Preview**
```bash
curl -X POST http://localhost:3000/api/voice/preview-extraction \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "recording_id": 123,
    "extraction_type": "both"
  }'
```

**Step 2: Review and Edit**
```json
{
  "preview": {
    "tasks": [
      {
        "title": "شراء مستلزمات",
        "subtasks": [...]
      }
    ]
  }
}
```

**Step 3: Create**
```bash
curl -X POST http://localhost:3000/api/voice/create-from-preview \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "recording_id": 123,
    "tasks": [...],
    "notes": [...]
  }'
```


---

## ❌ Error Handling

### Common Errors

#### 1. Authentication Error
```json
{
  "success": false,
  "error": "Unauthorized",
  "message": "Invalid or expired token",
  "statusCode": 401
}
```

**Solution:** Get a new token from `/api/auth/login`

---

#### 2. Recording Not Found
```json
{
  "success": false,
  "error": "Recording not found",
  "statusCode": 404
}
```

**Solution:** Check the recording_id is correct

---

#### 3. Invalid Audio Format
```json
{
  "success": false,
  "error": "Invalid audio format",
  "message": "Allowed formats: MP3, WAV, M4A, OGG, WEBM",
  "statusCode": 400
}
```

**Solution:** Convert your audio file to a supported format

---

#### 4. File Too Large
```json
{
  "success": false,
  "error": "File too large",
  "message": "Maximum file size is 10MB",
  "statusCode": 400
}
```

**Solution:** Compress your audio file or reduce quality

---

#### 5. Transcription Failed
```json
{
  "success": false,
  "error": "Transcription failed",
  "message": "AssemblyAI API key not configured",
  "statusCode": 500
}
```

**Solution:** Contact support or check server configuration

---

#### 6. AI Extraction Failed
```json
{
  "success": false,
  "error": "AI extraction failed",
  "message": "OpenRouter API error",
  "statusCode": 500
}
```

**Solution:** Retry the request or contact support

---

### Error Response Format

All errors follow this format:
```json
{
  "success": false,
  "error": "Error type",
  "message": "Detailed error message",
  "statusCode": 400
}
```

### HTTP Status Codes

- `200` - Success
- `201` - Created
- `400` - Bad Request (validation error)
- `401` - Unauthorized (invalid token)
- `404` - Not Found
- `500` - Internal Server Error


---

## 🎯 Best Practices

### 1. Use ONE-CLICK for Speed
If you want quick processing without preview, use `/process-complete`:
```bash
POST /api/voice/process-complete
```

### 2. Use Preview for Accuracy
If you want to review before creating, use the preview workflow:
```bash
1. POST /api/voice/upload
2. POST /api/voice/transcribe
3. POST /api/voice/preview-extraction
4. POST /api/voice/create-from-preview
```

### 3. Specify Language Correctly
Always specify the correct language for best transcription results:
```json
{
  "language": "ar"  // for Arabic
}
```

### 4. Use Clear Time References
Instead of vague terms, use specific times:
- ❌ "بعدين" (later)
- ✅ "بكرة الساعة 3 العصر" (tomorrow at 3 PM)

### 5. Separate Tasks from Notes
Use keywords to distinguish:
- Tasks: "عايز"، "محتاج"، "لازم"
- Notes: "نوت"، "ملاحظة"، "فكرة"

### 6. Optimize Audio Quality
- **File size:** < 10MB
- **Quality:** 128kbps is sufficient
- **Duration:** < 5 minutes for faster processing
- **Clarity:** Speak clearly without background noise

### 7. Handle Errors Gracefully
Always check the response status:
```javascript
const response = await fetch('/api/voice/process-complete', {
  method: 'POST',
  body: formData
});

if (!response.ok) {
  const error = await response.json();
  console.error('Error:', error.message);
  // Handle error
}

const result = await response.json();
// Process result
```

### 8. Use Pagination for Listings
When fetching recordings, use pagination:
```bash
GET /api/voice?page=1&limit=20
```

### 9. Clean Up Old Recordings
Delete recordings you no longer need:
```bash
DELETE /api/voice/:id
```

### 10. Test in Development First
Always test your integration in development before production:
```bash
API_BASE_URL=http://localhost:3000/api
```


---

## 🌍 Arabic Dialect Support

### Egyptian Dialect (اللهجة المصرية)
```
عايز أشتري لبن بكرة
محتاج أروح الشغل النهاردة
لازم أخلص المشروع دلوقتي
```

**Keywords:**
- عايز = I want
- محتاج = I need
- بكرة = tomorrow
- النهاردة = today
- دلوقتي = now

---

### Saudi/Gulf Dialect (اللهجة السعودية/الخليجية)
```
أبغى أشتري حليب باجر
ودي أروح الدوام اليوم
لازم أخلص المشروع الحين
```

**Keywords:**
- أبغى = I want
- ودي = I want
- باجر = tomorrow
- اليوم = today
- الحين = now

---

### Levantine Dialect (اللهجة الشامية)
```
بدي اشتري حليب بكرا
لازم روح الشغل اليوم
لازم خلص المشروع هلق
```

**Keywords:**
- بدي = I want
- بكرا = tomorrow
- اليوم = today
- هلق = now

---

### Moroccan Dialect (اللهجة المغربية)
```
بغيت نشري حليب غدا
خصني نمشي للخدمة اليوم
```

**Keywords:**
- بغيت = I want
- غدا = tomorrow
- اليوم = today


---

## ⏰ Time Understanding

### Times of Day (أوقات اليوم)
- **الفجر** = 5:00 AM
- **الصبح/الصباح** = 9:00 AM
- **الضحى** = 10:00 AM
- **الظهر** = 12:00 PM
- **العصر** = 3:00 PM
- **المغرب** = 6:00 PM
- **العشاء** = 8:00 PM
- **الليل** = 9:00 PM
- **منتصف الليل** = 12:00 AM

### Relative Dates (تواريخ نسبية)
- **اليوم/النهاردة** = Today
- **بكرة/باجر/بكرا** = Tomorrow
- **بعد بكرة** = Day after tomorrow
- **الأسبوع الجاي** = Next week
- **الشهر الجاي** = Next month
- **بعد 3 أيام** = In 3 days
- **بعد أسبوعين** = In 2 weeks

### Days of Week (أيام الأسبوع)
- **السبت** = Saturday
- **الأحد** = Sunday
- **الاثنين** = Monday
- **الثلاثاء** = Tuesday
- **الأربعاء** = Wednesday
- **الخميس** = Thursday
- **الجمعة** = Friday

### Specific Times (أوقات محددة)
- **الساعة 3** = 3:00
- **3 العصر** = 3:00 PM
- **5 الصبح** = 5:00 AM
- **10:30** = 10:30
- **بعد ساعتين** = In 2 hours
- **بعد 30 دقيقة** = In 30 minutes


---

## 🎯 Priority Detection

### High Priority
**Keywords:**
- مهم جداً، مهم جدا
- ضروري
- عاجل
- لازم
- حالاً، حالا
- فوراً، فورا
- أولوية قصوى
- مستعجل
- حرج
- طارئ

**Dialect-specific:**
- مهم أوي (Egyptian)
- مهم مرة (Saudi/Gulf)
- مهم كتير (Levantine)

**Example:**
> "مهم جداً أتصل بالدكتور" → priority: "high"

---

### Medium Priority
**Keywords:**
- مهم
- محتاج
- لازم
- يفضل
- مطلوب

**Example:**
> "محتاج أشتري لبن" → priority: "medium"

---

### Low Priority
**Keywords:**
- ممكن
- لو فاضي
- مش مستعجل
- لو تقدر
- لو سمحت
- في وقت فراغ
- مش مهم
- عادي
- لو تيسر
- على راحتك

**Dialect-specific:**
- على مهلك (Egyptian)
- ما فيه عجلة (Saudi/Gulf)

**Example:**
> "لو فاضي ممكن تشتري لبن" → priority: "low"


---

## 📝 Task vs Note Detection

### Task Indicators
**Action Verbs:**
- عايز، أريد، محتاج، ناوي، أبغى
- لازم، مفروض، يجب، ضروري
- اشتري، اتصل، راجع، جهز، أرسل، احجز، سجل
- اعمل، اكتب، روح، قابل، كلم، خلص، انهي، ابدأ

**Keywords:**
- مهمة، تاسك، task، todo
- موعد، اجتماع، meeting

**Example:**
> "عايز أشتري لبن" → Detected as **task**

---

### Note Indicators
**Keywords:**
- نوت، ملاحظة، فكرة، معلومة، تذكير
- مهم أعرف
- note، idea، information، reminder

**Example:**
> "نوت: لازم أركز على الأرقام" → Detected as **note**

---

### Mixed Content
If both tasks and notes are present, they will be separated:

**Input:**
> "محتاج أجهز العرض. نوت: ركز على الأرقام"

**Output:**
```json
{
  "tasks": [
    {"title": "تجهيز العرض"}
  ],
  "notes": [
    {"title": "ملاحظة", "content": "ركز على الأرقام"}
  ]
}
```


---

## 🔧 Configuration

### Environment Variables

```env
# AssemblyAI (for transcription)
ASSEMBLYAI_API_KEY=your_assemblyai_key_here

# OpenRouter (for AI extraction - preferred)
OPENROUTER_API_KEY=your_openrouter_key_here

# Gemini (fallback)
GEMINI_API_KEY=your_gemini_key_here

# Upload settings
MAX_FILE_SIZE=10485760  # 10MB
ALLOWED_FORMATS=audio/mpeg,audio/wav,audio/m4a,audio/ogg,audio/webm
```

### Getting API Keys

#### AssemblyAI
1. Go to https://www.assemblyai.com/
2. Sign up for free account
3. Get your API key from dashboard
4. Add to `.env`: `ASSEMBLYAI_API_KEY=your_key`

#### OpenRouter
1. Go to https://openrouter.ai/
2. Sign up for account
3. Get your API key
4. Add to `.env`: `OPENROUTER_API_KEY=your_key`

#### Gemini (Optional)
1. Go to https://makersuite.google.com/
2. Get API key
3. Add to `.env`: `GEMINI_API_KEY=your_key`


---

## 🧪 Testing

### Using cURL

```bash
# 1. Login to get token
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "password123"
  }'

# 2. Upload and process voice
curl -X POST http://localhost:3000/api/voice/process-complete \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -F "audio_file=@recording.mp3" \
  -F "language=ar"

# 3. Get all recordings
curl -X GET http://localhost:3000/api/voice \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Using Postman

1. Import collection: `Voclio_API_Collection.postman_collection.json`
2. Set environment variable: `token` = your JWT token
3. Test endpoints

### Using JavaScript

```javascript
// Login
const loginResponse = await fetch('/api/auth/login', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    email: 'user@example.com',
    password: 'password123'
  })
});
const { data: { token } } = await loginResponse.json();

// Upload voice
const formData = new FormData();
formData.append('audio_file', audioFile);
formData.append('language', 'ar');

const voiceResponse = await fetch('/api/voice/process-complete', {
  method: 'POST',
  headers: { 'Authorization': `Bearer ${token}` },
  body: formData
});
const result = await voiceResponse.json();
console.log(result);
```

### Using Python

```python
import requests

# Login
login_url = "http://localhost:3000/api/auth/login"
login_data = {
    "email": "user@example.com",
    "password": "password123"
}
login_response = requests.post(login_url, json=login_data)
token = login_response.json()["data"]["token"]

# Upload voice
voice_url = "http://localhost:3000/api/voice/process-complete"
headers = {"Authorization": f"Bearer {token}"}
files = {"audio_file": open("recording.mp3", "rb")}
data = {"language": "ar"}

voice_response = requests.post(voice_url, headers=headers, files=files, data=data)
result = voice_response.json()
print(result)
```

### Automated Testing

```bash
# Run test suite
npm run test:voice-apis

# Run AI tests
npm run test:ai
```


---

## 🚀 Quick Start

### 1. Setup

```bash
# Clone repository
git clone <repository-url>
cd voclio-api

# Install dependencies
npm install

# Setup environment
cp .env.example .env
# Edit .env and add your API keys

# Initialize database
npm run init-db

# Start server
npm run dev
```

### 2. Test Voice API

```bash
# Create a test audio file (record yourself saying):
# "عايز أشتري لبن وخبز بكرة الصبح"

# Run test
npm run test:voice-apis
```

### 3. Make Your First Request

```bash
# Get auth token
TOKEN=$(curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@voclio.com","password":"admin123"}' \
  | jq -r '.data.token')

# Upload and process voice
curl -X POST http://localhost:3000/api/voice/process-complete \
  -H "Authorization: Bearer $TOKEN" \
  -F "audio_file=@test-audio.mp3" \
  -F "language=ar"
```


---

## 📊 Performance & Limits

### File Limits
- **Maximum file size:** 10MB
- **Supported formats:** MP3, WAV, M4A, OGG, WEBM
- **Recommended quality:** 128kbps
- **Maximum duration:** No hard limit, but < 5 minutes recommended

### Rate Limits
- **Requests per minute:** 60
- **Requests per hour:** 1000
- **Concurrent uploads:** 5

### Processing Times
- **Upload:** < 1 second
- **Transcription:** 10-60 seconds (depends on audio length)
- **AI extraction:** 5-15 seconds
- **Total (ONE-CLICK):** 15-75 seconds

### Optimization Tips
1. **Compress audio:** Use 128kbps MP3 for best balance
2. **Keep it short:** < 5 minutes for faster processing
3. **Clear audio:** Reduce background noise
4. **Batch operations:** Use preview workflow for multiple edits


---

## 🔒 Security

### Authentication
- All endpoints require JWT token
- Tokens expire after 24 hours
- Refresh token before expiry

### File Upload Security
- File type validation
- File size limits
- Virus scanning (recommended in production)
- Secure file storage

### Data Privacy
- Recordings are user-specific
- No cross-user access
- Automatic cleanup of old files
- GDPR compliant

### Best Practices
1. **Never share tokens:** Keep JWT tokens secure
2. **Use HTTPS:** Always use HTTPS in production
3. **Validate input:** Client-side validation before upload
4. **Handle errors:** Don't expose sensitive error details
5. **Rate limiting:** Respect rate limits


---

## 🆘 Troubleshooting

### Issue: "Transcription failed"
**Possible causes:**
- AssemblyAI API key not configured
- Invalid audio format
- Audio file corrupted

**Solutions:**
1. Check `.env` file has `ASSEMBLYAI_API_KEY`
2. Verify audio format is supported
3. Try re-recording the audio

---

### Issue: "No tasks extracted"
**Possible causes:**
- Audio contains only notes/information
- Speech not clear
- Language mismatch

**Solutions:**
1. Use clear action verbs: "عايز"، "محتاج"، "لازم"
2. Speak clearly
3. Verify language parameter matches audio

---

### Issue: "File too large"
**Possible causes:**
- Audio file > 10MB
- High quality recording

**Solutions:**
1. Compress audio to 128kbps
2. Reduce recording duration
3. Use MP3 format

---

### Issue: "Invalid token"
**Possible causes:**
- Token expired
- Token not included in header
- Invalid token format

**Solutions:**
1. Login again to get new token
2. Check Authorization header format: `Bearer YOUR_TOKEN`
3. Verify token is not corrupted

---

### Issue: "Subtasks not extracted"
**Possible causes:**
- Items not clearly separated
- No list indicators

**Solutions:**
1. Use "و" (and) between items: "لبن و خبز و جبنة"
2. Use commas: "لبن، خبز، جبنة"
3. Use numbers: "أولاً لبن، ثانياً خبز"

---

### Issue: "Wrong date/time"
**Possible causes:**
- Ambiguous time reference
- Dialect not recognized

**Solutions:**
1. Be specific: "بكرة الساعة 3 العصر"
2. Use standard Arabic or supported dialects
3. Use numbers: "الساعة 15:00"


---

## 📞 Support & Resources

### Documentation
- **API Reference:** This document
- **Quick Start:** `QUICK_START_VOICE.md`
- **Improvements:** `VOICE_IMPROVEMENTS.md`
- **Full Docs:** `docs/VOICE_API_DOCUMENTATION.md`

### Code Examples
- **Test Suite:** `test-voice-apis.js`
- **AI Tests:** `test-ai-suggestions.js`
- **Postman Collection:** `Voclio_API_Collection.postman_collection.json`

### Getting Help
- **Email:** support@voclio.com
- **Documentation:** https://docs.voclio.app
- **GitHub Issues:** https://github.com/voclio/api/issues

### Community
- **Discord:** https://discord.gg/voclio
- **Twitter:** @VoclioApp
- **Blog:** https://blog.voclio.app

---

## 📝 Changelog

### v1.0.0 (2026-02-05)
- ✅ Initial release
- ✅ Multi-language transcription (13 languages)
- ✅ Arabic dialect support (4 dialects)
- ✅ Smart task extraction with subtasks
- ✅ Automatic date/time parsing
- ✅ Priority detection
- ✅ Note extraction with auto-tagging
- ✅ ONE-CLICK processing
- ✅ Preview before creation
- ✅ Comprehensive documentation

---

## 📄 License

MIT License - See LICENSE file for details

---

## 🙏 Acknowledgments

- **AssemblyAI** - Audio transcription
- **OpenRouter** - AI processing
- **Google Gemini** - Fallback AI
- **Voclio Team** - Development and support

---

**Made with ❤️ by Voclio Team**

**تم بحمد الله ✨**

---

*Last updated: February 5, 2026*
*Version: 1.0.0*
