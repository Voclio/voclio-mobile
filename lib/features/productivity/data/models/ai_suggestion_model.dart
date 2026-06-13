import 'package:voclio_app/features/productivity/domain/entities/ai_suggestion_entity.dart';

class AiSuggestionModel extends AiSuggestionEntity {
  AiSuggestionModel({
    required super.suggestions,
    required super.basedOn,
    super.dailyInsight,
    super.insightSource,
  });

  factory AiSuggestionModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    final rawSuggestions = data['suggestions'] as List<dynamic>? ?? [];
    final suggestionsList = rawSuggestions
        .map((item) {
          if (item is String) return item;
          if (item is Map) {
            return (item['text'] ?? item['suggestion'] ?? '').toString();
          }
          return item.toString();
        })
        .where((s) => s.isNotEmpty)
        .toList();

    final dailyInsightRaw = data['daily_insight'];
    String? dailyInsight;
    if (dailyInsightRaw is Map) {
      dailyInsight = (dailyInsightRaw['text'] ?? dailyInsightRaw['suggestion'])
          ?.toString();
    } else if (dailyInsightRaw is String) {
      dailyInsight = dailyInsightRaw;
    }

    final metadata = data['metadata'] as Map<String, dynamic>? ?? {};
    final insightSource =
        (metadata['insight_source'] ?? metadata['ai_provider'] ?? 'ai')
            .toString();

    final basedOnData = data['based_on'] ?? {};

    return AiSuggestionModel(
      suggestions: suggestionsList,
      dailyInsight: dailyInsight,
      insightSource: insightSource,
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
    super.completionRate,
  });

  factory AiSuggestionSummaryModel.fromJson(Map<String, dynamic> json) {
    final summary = json['summary'] as Map<String, dynamic>? ?? {};
    final tasksAnalysis =
        json['tasks_analysis'] as Map<String, dynamic>? ?? {};

    return AiSuggestionSummaryModel(
      focusDays: summary['focus_days'] ?? 0,
      totalFocusMinutes: summary['total_focus_minutes'] ?? 0,
      totalSessions: summary['total_sessions'] ?? 0,
      avgSessionMinutes: summary['avg_session_minutes']?.toString() ?? '0.00',
      tasksCompleted:
          tasksAnalysis['completed_tasks'] ??
          summary['tasks_completed'] ??
          0,
      currentStreak: summary['current_streak'] ?? 0,
      totalTasks:
          tasksAnalysis['total_tasks'] ?? json['total_tasks'] ?? 0,
      pendingTasks:
          tasksAnalysis['pending_tasks'] ?? json['pending_tasks'] ?? 0,
      overdueTasks:
          tasksAnalysis['overdue_tasks'] ?? json['overdue_tasks'] ?? 0,
      completionRate: tasksAnalysis['completion_rate'] ?? 0,
    );
  }
}
