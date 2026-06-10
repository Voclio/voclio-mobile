import 'package:voclio_app/features/dashboard/domain/entities/quick_stats_entity.dart';

class QuickStatsModel {
  final int todayTasks;
  final int pendingTasks;
  final int totalNotes;
  final int currentStreak;

  QuickStatsModel({
    required this.todayTasks,
    required this.pendingTasks,
    required this.totalNotes,
    required this.currentStreak,
  });

  factory QuickStatsModel.fromJson(Map<String, dynamic> json) {
    final tasks = json['tasks'] as Map<String, dynamic>? ?? {};
    final productivity = json['productivity'] as Map<String, dynamic>? ?? {};

    final totalTasks = tasks['total'] ?? json['todayTasks'] ?? 0;
    final completedTasks = tasks['completed'] ?? 0;

    return QuickStatsModel(
      todayTasks: totalTasks is int ? totalTasks : int.tryParse('$totalTasks') ?? 0,
      pendingTasks: (totalTasks is int ? totalTasks : int.tryParse('$totalTasks') ?? 0) -
          (completedTasks is int ? completedTasks : int.tryParse('$completedTasks') ?? 0),
      totalNotes: json['notes'] ?? json['totalNotes'] ?? 0,
      currentStreak: productivity['sessions'] ?? json['currentStreak'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'todayTasks': todayTasks,
      'pendingTasks': pendingTasks,
      'totalNotes': totalNotes,
      'currentStreak': currentStreak,
    };
  }

  QuickStatsEntity toEntity() {
    return QuickStatsEntity(
      todayTasks: todayTasks,
      pendingTasks: pendingTasks,
      totalNotes: totalNotes,
      currentStreak: currentStreak,
    );
  }
}
