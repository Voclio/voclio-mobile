import '../../domain/entities/task_extensions.dart';

class SubtaskModel {
  final String id;
  final String taskId;
  final String title;
  final bool completed;
  final int order;
  final DateTime createdAt;

  SubtaskModel({
    required this.id,
    required this.taskId,
    required this.title,
    required this.completed,
    required this.order,
    required this.createdAt,
  });

  factory SubtaskModel.fromJson(Map<String, dynamic> json) {
    return SubtaskModel(
      id: json['subtask_id'] ?? json['id'] ?? '',
      taskId: json['task_id'] ?? '',
      title: json['title'] ?? '',
      completed: json['completed'] ?? false,
      order: json['order'] ?? 0,
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'task_id': taskId,
      'title': title,
      'completed': completed,
      'order': order,
    };
  }

  SubtaskEntity toEntity() {
    return SubtaskEntity(
      id: id,
      taskId: taskId,
      title: title,
      completed: completed,
      order: order,
      createdAt: createdAt,
    );
  }
}

class TaskCategoryModel {
  final String id;
  final String name;
  final String color;
  final String icon;

  TaskCategoryModel({
    required this.id,
    required this.name,
    required this.color,
    required this.icon,
  });

  factory TaskCategoryModel.fromJson(Map<String, dynamic> json) {
    return TaskCategoryModel(
      id: json['category_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      color: json['color'] ?? '#3498db',
      icon: json['icon'] ?? '📁',
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'color': color, 'icon': icon};
  }

  TaskCategoryEntity toEntity() {
    return TaskCategoryEntity(id: id, name: name, color: color, icon: icon);
  }
}

class TaskStatisticsModel {
  final int totalTasks;
  final int completedTasks;
  final int pendingTasks;
  final int overdueTasks;
  final double completionRate;
  final Map<String, int> categoryBreakdown;

  TaskStatisticsModel({
    required this.totalTasks,
    required this.completedTasks,
    required this.pendingTasks,
    required this.overdueTasks,
    required this.completionRate,
    required this.categoryBreakdown,
  });

  factory TaskStatisticsModel.fromJson(Map<String, dynamic> json) {
    return TaskStatisticsModel(
      totalTasks: json['total_tasks'] ?? 0,
      completedTasks: json['completed_tasks'] ?? 0,
      pendingTasks: json['pending_tasks'] ?? 0,
      overdueTasks: json['overdue_tasks'] ?? 0,
      completionRate: (json['completion_rate'] ?? 0.0).toDouble(),
      categoryBreakdown:
          json['category_breakdown'] != null
              ? Map<String, int>.from(json['category_breakdown'])
              : {},
    );
  }

  TaskStatisticsEntity toEntity() {
    return TaskStatisticsEntity(
      totalTasks: totalTasks,
      completedTasks: completedTasks,
      pendingTasks: pendingTasks,
      overdueTasks: overdueTasks,
      completionRate: completionRate,
      categoryBreakdown: categoryBreakdown,
    );
  }
}
