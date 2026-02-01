import 'package:voclio_app/features/dashboard/domain/entities/dashboard_stats_entity.dart';

class DashboardStatsModel {
  final DashboardOverviewModel overview;
  final List<TaskModel> upcomingTasks;
  final List<NoteModel> recentNotes;
  final ProductivityStatsModel productivity;
  final List<QuickActionModel> quickActions;

  DashboardStatsModel({
    required this.overview,
    required this.upcomingTasks,
    required this.recentNotes,
    required this.productivity,
    required this.quickActions,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      overview: DashboardOverviewModel.fromJson(json['overview'] ?? {}),
      upcomingTasks:
          (json['upcoming_tasks'] as List<dynamic>?)
              ?.map((e) => TaskModel.fromJson(e))
              .toList() ??
          [],
      recentNotes:
          (json['recent_notes'] as List<dynamic>?)
              ?.map((e) => NoteModel.fromJson(e))
              .toList() ??
          [],
      productivity: ProductivityStatsModel.fromJson(json['productivity'] ?? {}),
      quickActions:
          (json['quick_actions'] as List<dynamic>?)
              ?.map((e) => QuickActionModel.fromJson(e))
              .toList() ??
          [],
    );
  }

  DashboardStatsEntity toEntity() {
    return DashboardStatsEntity(
      overview: overview.toEntity(),
      upcomingTasks: upcomingTasks.map((e) => e.toEntity()).toList(),
      recentNotes: recentNotes.map((e) => e.toEntity()).toList(),
      productivity: productivity.toEntity(),
      quickActions: quickActions.map((e) => e.toEntity()).toList(),
    );
  }
}

class DashboardOverviewModel {
  final int totalTasks;
  final int completedTasks;
  final int pendingTasks;
  final int overdueTasks;
  final double overallProgress;
  final int totalNotes;
  final int totalRecordings;
  final int totalAchievements;

  DashboardOverviewModel({
    required this.totalTasks,
    required this.completedTasks,
    required this.pendingTasks,
    required this.overdueTasks,
    required this.overallProgress,
    required this.totalNotes,
    required this.totalRecordings,
    required this.totalAchievements,
  });

  factory DashboardOverviewModel.fromJson(Map<String, dynamic> json) {
    return DashboardOverviewModel(
      totalTasks: json['total_tasks'] ?? 0,
      completedTasks: json['completed_tasks'] ?? 0,
      pendingTasks: json['pending_tasks'] ?? 0,
      overdueTasks: json['overdue_tasks'] ?? 0,
      overallProgress: (json['overall_progress'] ?? 0.0).toDouble(),
      totalNotes: json['total_notes'] ?? 0,
      totalRecordings: json['total_recordings'] ?? 0,
      totalAchievements: json['total_achievements'] ?? 0,
    );
  }

  DashboardOverview toEntity() {
    return DashboardOverview(
      totalTasks: totalTasks,
      completedTasks: completedTasks,
      pendingTasks: pendingTasks,
      overdueTasks: overdueTasks,
      overallProgress: overallProgress,
      totalNotes: totalNotes,
      totalRecordings: totalRecordings,
      totalAchievements: totalAchievements,
    );
  }
}

class TaskModel {
  final int id;
  final String title;
  final DateTime? dueDate;
  final String priority;
  final String status;
  final int? categoryId;

  TaskModel({
    required this.id,
    required this.title,
    this.dueDate,
    required this.priority,
    required this.status,
    this.categoryId,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['task_id'] ?? 0,
      title: json['title'] ?? '',
      dueDate:
          json['due_date'] != null ? DateTime.parse(json['due_date']) : null,
      priority: json['priority'] ?? 'medium',
      status: json['status'] ?? 'pending',
      categoryId: json['category_id'],
    );
  }

  TaskEntity toEntity() {
    return TaskEntity(
      id: id,
      title: title,
      dueDate: dueDate,
      priority: priority,
      status: status,
      categoryId: categoryId,
    );
  }
}

class NoteModel {
  final int id;
  final String title;
  final String preview;
  final DateTime createdAt;

  NoteModel({
    required this.id,
    required this.title,
    required this.preview,
    required this.createdAt,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['note_id'] ?? 0,
      title: json['title'] ?? '',
      preview: json['preview'] ?? '',
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
      preview: preview,
      createdAt: createdAt,
    );
  }
}

class ProductivityStatsModel {
  final int currentStreak;
  final int longestStreak;
  final int todayFocusMinutes;

  ProductivityStatsModel({
    required this.currentStreak,
    required this.longestStreak,
    required this.todayFocusMinutes,
  });

  factory ProductivityStatsModel.fromJson(Map<String, dynamic> json) {
    return ProductivityStatsModel(
      currentStreak: json['current_streak'] ?? 0,
      longestStreak: json['longest_streak'] ?? 0,
      todayFocusMinutes: json['today_focus_minutes'] ?? 0,
    );
  }

  ProductivityStats toEntity() {
    return ProductivityStats(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      todayFocusMinutes: todayFocusMinutes,
    );
  }
}

class QuickActionModel {
  final String id;
  final String label;
  final String icon;

  QuickActionModel({required this.id, required this.label, required this.icon});

  factory QuickActionModel.fromJson(Map<String, dynamic> json) {
    return QuickActionModel(
      id: json['id'] ?? '',
      label: json['label'] ?? '',
      icon: json['icon'] ?? '',
    );
  }

  QuickActionEntity toEntity() {
    return QuickActionEntity(id: id, label: label, icon: icon);
  }
}
