import 'package:equatable/equatable.dart';

class DashboardStatsEntity extends Equatable {
  final TaskStats taskStats;
  final NoteStats noteStats;
  final ProductivityStats productivityStats;
  final List<TaskEntity> upcomingTasks;
  final List<NoteEntity> recentNotes;

  const DashboardStatsEntity({
    required this.taskStats,
    required this.noteStats,
    required this.productivityStats,
    required this.upcomingTasks,
    required this.recentNotes,
  });

  @override
  List<Object?> get props => [
    taskStats,
    noteStats,
    productivityStats,
    upcomingTasks,
    recentNotes,
  ];
}

class TaskStats extends Equatable {
  final int totalTasks;
  final int completedTasks;
  final int pendingTasks;
  final int overdueTasks;
  final double completionRate;

  const TaskStats({
    required this.totalTasks,
    required this.completedTasks,
    required this.pendingTasks,
    required this.overdueTasks,
    required this.completionRate,
  });

  @override
  List<Object?> get props => [
    totalTasks,
    completedTasks,
    pendingTasks,
    overdueTasks,
    completionRate,
  ];
}

class NoteStats extends Equatable {
  final int totalNotes;
  final int notesThisWeek;
  final int notesThisMonth;

  const NoteStats({
    required this.totalNotes,
    required this.notesThisWeek,
    required this.notesThisMonth,
  });

  @override
  List<Object?> get props => [totalNotes, notesThisWeek, notesThisMonth];
}

class ProductivityStats extends Equatable {
  final int currentStreak;
  final int longestStreak;
  final int totalFocusTime;
  final int focusSessionsCompleted;

  const ProductivityStats({
    required this.currentStreak,
    required this.longestStreak,
    required this.totalFocusTime,
    required this.focusSessionsCompleted,
  });

  @override
  List<Object?> get props => [
    currentStreak,
    longestStreak,
    totalFocusTime,
    focusSessionsCompleted,
  ];
}

class TaskEntity extends Equatable {
  final String id;
  final String title;
  final String? description;
  final DateTime? dueDate;
  final String priority;
  final bool isDone;

  const TaskEntity({
    required this.id,
    required this.title,
    this.description,
    this.dueDate,
    required this.priority,
    required this.isDone,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    dueDate,
    priority,
    isDone,
  ];
}

class NoteEntity extends Equatable {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;

  const NoteEntity({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, title, content, createdAt];
}
