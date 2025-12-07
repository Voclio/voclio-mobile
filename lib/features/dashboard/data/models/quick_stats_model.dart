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
    return QuickStatsModel(
      todayTasks: json['todayTasks'] ?? 0,
      pendingTasks: json['pendingTasks'] ?? 0,
      totalNotes: json['totalNotes'] ?? 0,
      currentStreak: json['currentStreak'] ?? 0,
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
