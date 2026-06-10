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
    final taskStats = json['taskStats'] ?? json['task_stats'];
    final noteStats = json['noteStats'] ?? json['note_stats'];

    Map<String, dynamic> overviewJson =
        Map<String, dynamic>.from(json['overview'] as Map? ?? {});
    if (overviewJson.isEmpty && taskStats is Map) {
      overviewJson = {
        'total_tasks': taskStats['totalTasks'] ?? taskStats['total_tasks'],
        'completed_tasks':
            taskStats['completedTasks'] ?? taskStats['completed_tasks'],
        'pending_tasks': taskStats['pendingTasks'] ?? taskStats['pending_tasks'],
        'overdue_tasks': taskStats['overdueTasks'] ?? taskStats['overdue_tasks'],
        'overall_progress':
            taskStats['completionRate'] ?? taskStats['overall_progress'],
        'total_notes': noteStats is Map
            ? (noteStats['totalNotes'] ?? noteStats['total_notes'])
            : 0,
      };
    }

    final upcomingRaw = json['upcoming_tasks'] ?? json['upcomingTasks'];
    final recentRaw = json['recent_notes'] ?? json['recentNotes'];
    final productivityJson =
        json['productivity'] ?? json['productivityStats'] ?? {};

    return DashboardStatsModel(
      overview: DashboardOverviewModel.fromJson(overviewJson),
      upcomingTasks: (upcomingRaw as List<dynamic>?)
              ?.map((e) => TaskModel.fromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          [],
      recentNotes: (recentRaw as List<dynamic>?)
              ?.map((e) => NoteModel.fromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          [],
      productivity: ProductivityStatsModel.fromJson(
        Map<String, dynamic>.from(productivityJson as Map? ?? {}),
      ),
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
      totalTasks: json['total_tasks'] ?? json['totalTasks'] ?? 0,
      completedTasks: json['completed_tasks'] ?? json['completedTasks'] ?? 0,
      pendingTasks: json['pending_tasks'] ?? json['pendingTasks'] ?? 0,
      overdueTasks: json['overdue_tasks'] ?? json['overdueTasks'] ?? 0,
      overallProgress:
          (json['overall_progress'] ?? json['completionRate'] ?? 0.0).toDouble(),
      totalNotes: json['total_notes'] ?? json['totalNotes'] ?? 0,
      totalRecordings: json['total_recordings'] ?? json['totalRecordings'] ?? 0,
      totalAchievements:
          json['total_achievements'] ?? json['totalAchievements'] ?? 0,
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
      id: _parseId(json['task_id'] ?? json['id']),
      title: json['title'] ?? '',
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'].toString())
          : null,
      priority: json['priority'] ?? 'medium',
      status: json['status'] ?? (json['is_done'] == true ? 'completed' : 'pending'),
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
      id: _parseId(json['note_id'] ?? json['id']),
      title: json['title'] ?? '',
      preview: json['preview'] ?? json['content'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
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
      currentStreak: json['current_streak'] ?? json['currentStreak'] ?? 0,
      longestStreak: json['longest_streak'] ?? json['longestStreak'] ?? 0,
      todayFocusMinutes:
          json['today_focus_minutes'] ?? json['totalFocusTime'] ?? 0,
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

int _parseId(dynamic raw) {
  if (raw is int) return raw;
  if (raw is String) {
    return int.tryParse(raw) ?? raw.hashCode.abs() % 100000;
  }
  return 0;
}
