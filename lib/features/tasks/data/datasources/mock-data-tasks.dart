import 'package:voclio_app/core/enums/enums.dart';
import 'package:voclio_app/features/tasks/domain/entities/task_entity.dart';

// Helper to keep dates dynamic relative to "Now"
final DateTime _now = DateTime.now();
final DateTime _today = DateTime(_now.year, _now.month, _now.day);
final DateTime _tomorrow = _today.add(const Duration(days: 1));
final DateTime _later = _today.add(const Duration(days: 3));

List<TaskEntity> mockTasks = [
  // 1. COMPLEX TASK
  TaskEntity(
    id: 't-001',
    title: 'Finish math homework',
    description:
        'Complete all exercises from pages 45-52 in the textbook. Focus on quadratic equations and graphing.',
    date: _now.add(const Duration(hours: 3)),
    createdAt: _now.subtract(const Duration(hours: 2)),
    isDone: false,
    priority: TaskPriority.high,
    tags: const ['Study'],
    relatedNoteId: 'n-101',
    subtasks: const [
      SubTask(id: 'st-1', title: 'Review chapter 1-3', isDone: true),
      SubTask(id: 'st-2', title: 'Complete practice problems', isDone: false),
      SubTask(id: 'st-3', title: 'Check answers', isDone: false),
    ],
  ),

  // 2. COMPLETED TASK
  TaskEntity(
    id: 't-002',
    title: 'Gym session',
    description: 'Leg day routine + 20 mins cardio.',
    date: _now.add(const Duration(hours: 6)),
    createdAt: _now.subtract(const Duration(hours: 5)),
    isDone: true,
    priority: TaskPriority.medium,
    tags: const ['Health'],
    subtasks: const [],
  ),

  // 3. TOMORROW TASK
  TaskEntity(
    id: 't-003',
    title: 'Team meeting prep',
    description: 'Prepare slides for Q4 planning.',
    date: _tomorrow.add(const Duration(hours: 10)),
    createdAt: _now.subtract(const Duration(days: 1)),
    isDone: false,
    priority: TaskPriority.high,
    tags: const ['Work'],
    subtasks: const [
      SubTask(id: 'st-4', title: 'Gather metrics', isDone: false),
      SubTask(id: 'st-5', title: 'Update slides', isDone: false),
    ],
  ),

  // 4. TOMORROW TASK 2
  TaskEntity(
    id: 't-004',
    title: 'Read chapter 5',
    date: _tomorrow.add(const Duration(hours: 14)),
    createdAt: _now,
    isDone: false,
    priority: TaskPriority.medium,
    tags: const ['Study'],
  ),

  // 5. LATER TASK
  TaskEntity(
    id: 't-005',
    title: 'Call dentist',
    description: 'Schedule annual cleaning.',
    date: _later.add(const Duration(hours: 9)),
    createdAt: _now.subtract(const Duration(days: 2)),
    isDone: false,
    priority: TaskPriority.low,
    tags: const ['Personal'],
  ),

  // 6. NO PRIORITY TASK
  TaskEntity(
    id: 't-006',
    title: 'Buy groceries',
    date: _today.add(const Duration(days: 7)),
    createdAt: _now,
    isDone: false,
    priority: TaskPriority.low,
    tags: const ['Personal', 'Health'],
  ),
];
