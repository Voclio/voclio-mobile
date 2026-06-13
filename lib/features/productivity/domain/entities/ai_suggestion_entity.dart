class AiSuggestionEntity {
  final List<String> suggestions;
  final String? dailyInsight;
  final String insightSource;
  final AiSuggestionSummaryEntity basedOn;

  AiSuggestionEntity({
    required this.suggestions,
    required this.basedOn,
    this.dailyInsight,
    this.insightSource = 'ai',
  });

  String get displayInsight {
    if (dailyInsight != null && dailyInsight!.trim().isNotEmpty) {
      return dailyInsight!.trim();
    }
    if (suggestions.isNotEmpty) {
      return suggestions.first;
    }
    return basedOn.fallbackInsight;
  }

  AiSuggestionEntity copyWith({
    List<String>? suggestions,
    AiSuggestionSummaryEntity? basedOn,
    String? dailyInsight,
    String? insightSource,
  }) {
    return AiSuggestionEntity(
      suggestions: suggestions ?? this.suggestions,
      basedOn: basedOn ?? this.basedOn,
      dailyInsight: dailyInsight ?? this.dailyInsight,
      insightSource: insightSource ?? this.insightSource,
    );
  }
}

class AiSuggestionSummaryEntity {
  final int focusDays;
  final int totalFocusMinutes;
  final int totalSessions;
  final String avgSessionMinutes;
  final int tasksCompleted;
  final int currentStreak;
  final int totalTasks;
  final int pendingTasks;
  final int overdueTasks;
  final int completionRate;

  AiSuggestionSummaryEntity({
    required this.focusDays,
    required this.totalFocusMinutes,
    required this.totalSessions,
    required this.avgSessionMinutes,
    required this.tasksCompleted,
    required this.currentStreak,
    required this.totalTasks,
    required this.pendingTasks,
    required this.overdueTasks,
    this.completionRate = 0,
  });

  String get fallbackInsight {
    if (overdueTasks > 0) {
      return overdueTasks == 1
          ? 'You have 1 overdue task. Reschedule it or complete it today to stay on track.'
          : 'You have $overdueTasks overdue tasks. Tackle the most urgent one first.';
    }
    if (totalTasks == 0) {
      return 'Record a task by voice — Voclio will add it to your calendar automatically.';
    }
    if (pendingTasks > 0) {
      return pendingTasks == 1
          ? 'You have 1 pending task. Set a specific time today to get it done.'
          : 'You have $pendingTasks pending tasks. Pick your top 3 and schedule them.';
    }
    if (completionRate < 50) {
      return 'Your completion rate is $completionRate%. Break tasks into smaller steps to build momentum.';
    }
    return 'You are on track. Review your calendar and capture new tasks by voice while they are fresh.';
  }
}
