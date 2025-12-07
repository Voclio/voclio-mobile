import 'package:equatable/equatable.dart';

class SubtaskEntity extends Equatable {
  final String id;
  final String taskId;
  final String title;
  final bool completed;
  final int order;
  final DateTime createdAt;

  const SubtaskEntity({
    required this.id,
    required this.taskId,
    required this.title,
    required this.completed,
    required this.order,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, taskId, title, completed, order, createdAt];
}

class TaskCategoryEntity extends Equatable {
  final String id;
  final String name;
  final String color;
  final String icon;

  const TaskCategoryEntity({
    required this.id,
    required this.name,
    required this.color,
    required this.icon,
  });

  @override
  List<Object?> get props => [id, name, color, icon];
}

class TaskStatisticsEntity extends Equatable {
  final int totalTasks;
  final int completedTasks;
  final int pendingTasks;
  final int overdueTasks;
  final double completionRate;
  final Map<String, int> categoryBreakdown;

  const TaskStatisticsEntity({
    required this.totalTasks,
    required this.completedTasks,
    required this.pendingTasks,
    required this.overdueTasks,
    required this.completionRate,
    required this.categoryBreakdown,
  });

  @override
  List<Object?> get props => [
    totalTasks,
    completedTasks,
    pendingTasks,
    overdueTasks,
    completionRate,
    categoryBreakdown,
  ];
}
