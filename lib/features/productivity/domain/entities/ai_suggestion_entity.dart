class AiSuggestionEntity {
  final List<String> suggestions;
  final AiSuggestionSummaryEntity basedOn;

  AiSuggestionEntity({required this.suggestions, required this.basedOn});

  AiSuggestionEntity copyWith({
    List<String>? suggestions,
    AiSuggestionSummaryEntity? basedOn,
  }) {
    return AiSuggestionEntity(
      suggestions: suggestions ?? this.suggestions,
      basedOn: basedOn ?? this.basedOn,
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
  });
}
