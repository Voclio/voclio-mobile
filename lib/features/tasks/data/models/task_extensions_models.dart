import '../../domain/entities/task_extensions.dart';

int _int(dynamic value) => int.tryParse(value?.toString() ?? '') ?? 0;

double _double(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

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
      id: (json['subtask_id'] ?? json['task_id'] ?? json['id'] ?? '').toString(),
      taskId: (json['parent_task_id'] ?? json['task_id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      completed: json['completed'] == true || json['status'] == 'completed',
      order: int.tryParse((json['order'] ?? 0).toString()) ?? 0,
      createdAt:
          json['created_at'] != null
              ? DateTime.tryParse(json['created_at'].toString()) ??
                  DateTime.now()
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
      id: (json['category_id'] ?? json['id'] ?? '').toString(),
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
      totalTasks: _int(json['total_tasks'] ?? json['total']),
      completedTasks: _int(json['completed_tasks'] ?? json['completed']),
      pendingTasks: _int(json['pending_tasks'] ?? json['todo']),
      overdueTasks: _int(json['overdue_tasks'] ?? json['overdue']),
      completionRate: _double(json['completion_rate'] ?? json['overall_progress']),
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
