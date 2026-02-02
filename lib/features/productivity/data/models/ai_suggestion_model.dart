import 'package:voclio_app/features/productivity/domain/entities/ai_suggestion_entity.dart';

class AiSuggestionModel extends AiSuggestionEntity {
  AiSuggestionModel({required super.suggestions, required super.basedOn});

  factory AiSuggestionModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    final suggestionsList = List<String>.from(data['suggestions'] ?? []);

    final basedOnData = data['based_on'] ?? {};

    return AiSuggestionModel(
      suggestions: suggestionsList,
      basedOn: AiSuggestionSummaryModel.fromJson(basedOnData),
    );
  }
}

class AiSuggestionSummaryModel extends AiSuggestionSummaryEntity {
  AiSuggestionSummaryModel({
    required super.focusDays,
    required super.totalFocusMinutes,
    required super.totalSessions,
    required super.avgSessionMinutes,
    required super.tasksCompleted,
    required super.currentStreak,
    required super.totalTasks,
    required super.pendingTasks,
    required super.overdueTasks,
  });

  factory AiSuggestionSummaryModel.fromJson(Map<String, dynamic> json) {
    final summary = json['summary'] ?? {};
    return AiSuggestionSummaryModel(
      focusDays: summary['focus_days'] ?? 0,
      totalFocusMinutes: summary['total_focus_minutes'] ?? 0,
      totalSessions: summary['total_sessions'] ?? 0,
      avgSessionMinutes: summary['avg_session_minutes']?.toString() ?? "0.00",
      tasksCompleted: summary['tasks_completed'] ?? 0,
      currentStreak: summary['current_streak'] ?? 0,
      totalTasks: json['total_tasks'] ?? 0,
      pendingTasks: json['pending_tasks'] ?? 0,
      overdueTasks: json['overdue_tasks'] ?? 0,
    );
  }
}
