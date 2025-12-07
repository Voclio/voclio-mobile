import 'package:voclio_app/core/enums/enums.dart';
import 'package:voclio_app/features/tasks/domain/entities/task_entity.dart'; // Adjust import path

//
// Helper to keep dates dynamic relative to "Now"
final DateTime _now = DateTime.now();
final DateTime _today = DateTime(_now.year, _now.month, _now.day);
final DateTime _tomorrow = _today.add(const Duration(days: 1));
final DateTime _later = _today.add(const Duration(days: 3));

List<TaskEntity> mockTasks = [
  // 1. COMPLEX TASK (Matches Design: "Finish math homework")
  TaskEntity(
    id: 't-001',
    title: 'Finish math homework',
    description:
        'Complete all exercises from pages 45-52 in the textbook. Focus on quadratic equations and graphing.',
    date: _now.add(const Duration(hours: 3)), // Due in 3 hours (Today)
    createdAt: _now.subtract(const Duration(hours: 2)),
    isDone:
        false, // In the design details it looks active, in the list it looks checked. Let's keep it active for testing.
    priority: TaskPriority.high,
    tags: const [AppTag.study],
    relatedNoteId: 'n-101', // Links to "Math homework notes"
    subtasks: const [
      SubTask(id: 'st-1', title: 'Review chapter 1-3', isDone: true),
      SubTask(id: 'st-2', title: 'Complete practice problems', isDone: false),
      SubTask(id: 'st-3', title: 'Check answers', isDone: false),
    ],
  ),

  // 2. COMPLETED TASK (Matches Design: "Gym session")
  TaskEntity(
    id: 't-002',
    title: 'Gym session',
    description: 'Leg day routine + 20 mins cardio.',
    date: _now.add(const Duration(hours: 6)), // Today later
    createdAt: _now.subtract(const Duration(hours: 5)),
    isDone: true,
    priority: TaskPriority.medium,
    tags: const [AppTag.health],
    subtasks: const [],
  ),

  // 3. TOMORROW TASK (Matches Design: "Team meeting prep")
  TaskEntity(
    id: 't-003',
    title: 'Team meeting prep',
    description: 'Prepare slides for Q4 planning.',
    date: _tomorrow.add(const Duration(hours: 10)), // Tomorrow 10 AM
    createdAt: _now.subtract(const Duration(days: 1)),
    isDone: false,
    priority: TaskPriority.high,
    tags: const [AppTag.work],
    subtasks: const [
      SubTask(id: 'st-4', title: 'Gather metrics', isDone: false),
      SubTask(id: 'st-5', title: 'Update slides', isDone: false),
    ],
  ),

  // 4. TOMORROW TASK 2 (Matches Design: "Read chapter 5")
  TaskEntity(
    id: 't-004',
    title: 'Read chapter 5',
    date: _tomorrow.add(const Duration(hours: 14)), // Tomorrow 2 PM
    createdAt: _now,
    isDone: false,
    priority: TaskPriority.medium,
    tags: const [AppTag.study],
  ),

  // 5. LATER TASK (Matches Design: "Call dentist")
  TaskEntity(
    id: 't-005',
    title: 'Call dentist',
    description: 'Schedule annual cleaning.',
    date: _later.add(const Duration(hours: 9)), // 3 days from now
    createdAt: _now.subtract(const Duration(days: 2)),
    isDone: false,
    priority: TaskPriority.low, // Assuming Low/Personal
    tags: const [AppTag.personal],
  ),

  // 6. NO PRIORITY TASK
  TaskEntity(
    id: 't-006',
    title: 'Buy groceries',
    date: _today.add(const Duration(days: 7)),
    createdAt: _now,
    isDone: false,
    priority: TaskPriority.low, // or none if you added that
    tags: const [AppTag.personal, AppTag.health],
  ),
];
