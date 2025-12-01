import 'package:voclio_app/core/enums/enums.dart';
import 'package:voclio_app/features/notes/domain/entities/note_entity.dart';

final DateTime _now = DateTime.now();

List<NoteEntity> mockNotes = [
  // 1. PROJECT IDEAS (Matches Design)
  NoteEntity(
    id: 'n-101',
    title: 'Project ideas brainstorm',
    content:
        'Need to explore the concept of integrating AI with daily planning tools. Users want seamless voice input, smart organization, and beautiful design.\n\nKey features to consider:\n- Voice-to-text transcription\n- Automatic categorization\n- Smart task extraction',
    lastEditDate: _now.subtract(const Duration(hours: 2)),
    creationDate: _now.subtract(const Duration(days: 1)),
    tags: const [AppTag.work, AppTag.ideas, AppTag.planning],
    voiceToTextDuration: "02:15",
  ),

  // 2. BOOK RECOMMENDATIONS (Matches Design)
  NoteEntity(
    id: 'n-102',
    title: 'Book recommendations',
    content:
        'Friends suggested these amazing books: Atomic Habits, Deep Work, Clean Code, The Pragmatic Programmer.',
    lastEditDate: _now.subtract(const Duration(hours: 5)),
    creationDate: _now.subtract(const Duration(days: 2)),
    tags: const [
      AppTag.personal,
      AppTag.reading,
    ], // You might need to add 'reading' to your Enum
  ),

  // 3. MEETING NOTES (Matches Design)
  NoteEntity(
    id: 'n-103',
    title: 'Meeting notes - Q4 Planning',
    content:
        'Discussed quarterly goals, team restructuring, and new product launches. Action items included updating the roadmap and scheduling 1:1s.',
    lastEditDate: _now.subtract(const Duration(days: 1)),
    creationDate: _now.subtract(const Duration(days: 1)),
    tags: const [
      AppTag.work,
      AppTag.meeting,
    ], // You might need to add 'meeting'
  ),

  // 4. OLDER NOTE
  NoteEntity(
    id: 'n-104',
    title: 'Grocery List',
    content: 'Milk, Eggs, Bread, Spinach, Chicken Breast, Rice.',
    lastEditDate: _now.subtract(const Duration(days: 5)),
    creationDate: _now.subtract(const Duration(days: 6)),
    tags: const [AppTag.personal, AppTag.health],
  ),
];
