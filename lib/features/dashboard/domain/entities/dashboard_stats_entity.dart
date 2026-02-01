import 'package:equatable/equatable.dart';

class DashboardStatsEntity extends Equatable {
  final DashboardOverview overview;
  final List<TaskEntity> upcomingTasks;
  final List<NoteEntity> recentNotes;
  final ProductivityStats productivity;
  final List<QuickActionEntity> quickActions;

  const DashboardStatsEntity({
    required this.overview,
    required this.upcomingTasks,
    required this.recentNotes,
    required this.productivity,
    required this.quickActions,
  });

  @override
  List<Object?> get props => [
    overview,
    upcomingTasks,
    recentNotes,
    productivity,
    quickActions,
  ];
}

class DashboardOverview extends Equatable {
  final int totalTasks;
  final int completedTasks;
  final int pendingTasks;
  final int overdueTasks;
  final double overallProgress;
  final int totalNotes;
  final int totalRecordings;
  final int totalAchievements;

  const DashboardOverview({
    required this.totalTasks,
    required this.completedTasks,
    required this.pendingTasks,
    required this.overdueTasks,
    required this.overallProgress,
    required this.totalNotes,
    required this.totalRecordings,
    required this.totalAchievements,
  });

  @override
  List<Object?> get props => [
    totalTasks,
    completedTasks,
    pendingTasks,
    overdueTasks,
    overallProgress,
    totalNotes,
    totalRecordings,
    totalAchievements,
  ];
}

class TaskEntity extends Equatable {
  final int id;
  final String title;
  final DateTime? dueDate;
  final String priority;
  final String status;
  final int? categoryId;

  const TaskEntity({
    required this.id,
    required this.title,
    this.dueDate,
    required this.priority,
    required this.status,
    this.categoryId,
  });

  @override
  List<Object?> get props => [id, title, dueDate, priority, status, categoryId];
}

class NoteEntity extends Equatable {
  final int id;
  final String title;
  final String preview;
  final DateTime createdAt;

  const NoteEntity({
    required this.id,
    required this.title,
    required this.preview,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, title, preview, createdAt];
}

class ProductivityStats extends Equatable {
  final int currentStreak;
  final int longestStreak;
  final int todayFocusMinutes;

  const ProductivityStats({
    required this.currentStreak,
    required this.longestStreak,
    required this.todayFocusMinutes,
  });

  @override
  List<Object?> get props => [currentStreak, longestStreak, todayFocusMinutes];
}

class QuickActionEntity extends Equatable {
  final String id;
  final String label;
  final String icon;

  const QuickActionEntity({
    required this.id,
    required this.label,
    required this.icon,
  });

  @override
  List<Object?> get props => [id, label, icon];
}
