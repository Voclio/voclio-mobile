import 'package:voclio_app/features/dashboard/domain/entities/dashboard_stats_entity.dart';

class DashboardStatsModel {
  final TaskStatsModel taskStats;
  final NoteStatsModel noteStats;
  final ProductivityStatsModel productivityStats;
  final List<TaskModel> upcomingTasks;
  final List<NoteModel> recentNotes;

  DashboardStatsModel({
    required this.taskStats,
    required this.noteStats,
    required this.productivityStats,
    required this.upcomingTasks,
    required this.recentNotes,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      taskStats: TaskStatsModel.fromJson(json['taskStats'] ?? {}),
      noteStats: NoteStatsModel.fromJson(json['noteStats'] ?? {}),
      productivityStats: ProductivityStatsModel.fromJson(
        json['productivityStats'] ?? {},
      ),
      upcomingTasks:
          (json['upcomingTasks'] as List<dynamic>?)
              ?.map((e) => TaskModel.fromJson(e))
              .toList() ??
          [],
      recentNotes:
          (json['recentNotes'] as List<dynamic>?)
              ?.map((e) => NoteModel.fromJson(e))
              .toList() ??
          [],
    );
  }

  DashboardStatsEntity toEntity() {
    return DashboardStatsEntity(
      taskStats: taskStats.toEntity(),
      noteStats: noteStats.toEntity(),
      productivityStats: productivityStats.toEntity(),
      upcomingTasks: upcomingTasks.map((e) => e.toEntity()).toList(),
      recentNotes: recentNotes.map((e) => e.toEntity()).toList(),
    );
  }
}

class TaskStatsModel {
  final int totalTasks;
  final int completedTasks;
  final int pendingTasks;
  final int overdueTasks;
  final double completionRate;

  TaskStatsModel({
    required this.totalTasks,
    required this.completedTasks,
    required this.pendingTasks,
    required this.overdueTasks,
    required this.completionRate,
  });

  factory TaskStatsModel.fromJson(Map<String, dynamic> json) {
    return TaskStatsModel(
      totalTasks: json['totalTasks'] ?? 0,
      completedTasks: json['completedTasks'] ?? 0,
      pendingTasks: json['pendingTasks'] ?? 0,
      overdueTasks: json['overdueTasks'] ?? 0,
      completionRate: (json['completionRate'] ?? 0.0).toDouble(),
    );
  }

  TaskStats toEntity() {
    return TaskStats(
      totalTasks: totalTasks,
      completedTasks: completedTasks,
      pendingTasks: pendingTasks,
      overdueTasks: overdueTasks,
      completionRate: completionRate,
    );
  }
}

class NoteStatsModel {
  final int totalNotes;
  final int notesThisWeek;
  final int notesThisMonth;

  NoteStatsModel({
    required this.totalNotes,
    required this.notesThisWeek,
    required this.notesThisMonth,
  });

  factory NoteStatsModel.fromJson(Map<String, dynamic> json) {
    return NoteStatsModel(
      totalNotes: json['totalNotes'] ?? 0,
      notesThisWeek: json['notesThisWeek'] ?? 0,
      notesThisMonth: json['notesThisMonth'] ?? 0,
    );
  }

  NoteStats toEntity() {
    return NoteStats(
      totalNotes: totalNotes,
      notesThisWeek: notesThisWeek,
      notesThisMonth: notesThisMonth,
    );
  }
}

class ProductivityStatsModel {
  final int currentStreak;
  final int longestStreak;
  final int totalFocusTime;
  final int focusSessionsCompleted;

  ProductivityStatsModel({
    required this.currentStreak,
    required this.longestStreak,
    required this.totalFocusTime,
    required this.focusSessionsCompleted,
  });

  factory ProductivityStatsModel.fromJson(Map<String, dynamic> json) {
    return ProductivityStatsModel(
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      totalFocusTime: json['totalFocusTime'] ?? 0,
      focusSessionsCompleted: json['focusSessionsCompleted'] ?? 0,
    );
  }

  ProductivityStats toEntity() {
    return ProductivityStats(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      totalFocusTime: totalFocusTime,
      focusSessionsCompleted: focusSessionsCompleted,
    );
  }
}

class TaskModel {
  final String id;
  final String title;
  final String? description;
  final DateTime? dueDate;
  final String priority;
  final bool isDone;

  TaskModel({
    required this.id,
    required this.title,
    this.description,
    this.dueDate,
    required this.priority,
    required this.isDone,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['task_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      dueDate:
          json['due_date'] != null ? DateTime.parse(json['due_date']) : null,
      priority: json['priority'] ?? 'medium',
      isDone: json['is_done'] ?? json['isDone'] ?? false,
    );
  }

  TaskEntity toEntity() {
    return TaskEntity(
      id: id,
      title: title,
      description: description,
      dueDate: dueDate,
      priority: priority,
      isDone: isDone,
    );
  }
}

class NoteModel {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;

  NoteModel({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['note_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : DateTime.now(),
    );
  }

  NoteEntity toEntity() {
    return NoteEntity(
      id: id,
      title: title,
      content: content,
      createdAt: createdAt,
    );
  }
}
