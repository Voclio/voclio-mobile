import 'package:equatable/equatable.dart';

class QuickStatsEntity extends Equatable {
  final int todayTasks;
  final int pendingTasks;
  final int totalNotes;
  final int currentStreak;

  const QuickStatsEntity({
    required this.todayTasks,
    required this.pendingTasks,
    required this.totalNotes,
    required this.currentStreak,
  });

  @override
  List<Object?> get props => [
    todayTasks,
    pendingTasks,
    totalNotes,
    currentStreak,
  ];
}
