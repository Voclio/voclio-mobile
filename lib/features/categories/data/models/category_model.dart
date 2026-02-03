class CategoryModel {
  final String id;
  final String name;
  final String color;
  final String? description;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CategoryModel({
    required this.id,
    required this.name,
    required this.color,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: (json['category_id'] ?? json['id'] ?? '').toString(),
      name: json['name'] ?? '',
      color: json['color'] ?? '#3498db',
      description: json['description'],
      createdAt:
          json['created_at'] != null
              ? DateTime.tryParse(json['created_at'].toString())
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.tryParse(json['updated_at'].toString())
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'color': color,
      if (description != null) 'description': description,
    };
  }

  CategoryModel copyWith({
    String? id,
    String? name,
    String? color,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class CategoryStatsModel {
  final int totalTasks;
  final int completedTasks;
  final int pendingTasks;
  final double completionRate;

  CategoryStatsModel({
    required this.totalTasks,
    required this.completedTasks,
    required this.pendingTasks,
    required this.completionRate,
  });

  factory CategoryStatsModel.fromJson(Map<String, dynamic> json) {
    return CategoryStatsModel(
      totalTasks: json['total_tasks'] ?? json['totalTasks'] ?? 0,
      completedTasks: json['completed_tasks'] ?? json['completedTasks'] ?? 0,
      pendingTasks: json['pending_tasks'] ?? json['pendingTasks'] ?? 0,
      completionRate:
          (json['completion_rate'] ?? json['completionRate'] ?? 0.0).toDouble(),
    );
  }
}
