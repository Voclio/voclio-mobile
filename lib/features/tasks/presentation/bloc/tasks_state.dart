import 'package:equatable/equatable.dart';
import 'package:voclio_app/features/tasks/domain/entities/task_entity.dart';
import 'package:voclio_app/features/tasks/domain/entities/task_extensions.dart';
import 'package:voclio_app/core/domain/entities/tag_entity.dart';

enum TasksStatus { initial, loading, success, failure }

class TasksState extends Equatable {
  final TasksStatus status;
  final List<TaskEntity> tasks;
  final String errorMessage;
  final List<TaskCategoryEntity> categories;
  final String? selectedCategoryId;
  final List<TagEntity> availableTags;

  const TasksState({
    this.status = TasksStatus.initial,
    this.tasks = const [],
    this.errorMessage = '',
    this.categories = const [],
    this.selectedCategoryId,
    this.availableTags = const [],
  });

  TasksState copyWith({
    TasksStatus? status,
    List<TaskEntity>? tasks,
    String? errorMessage,
    List<TaskCategoryEntity>? categories,
    String? selectedCategoryId,
    List<TagEntity>? availableTags,
  }) {
    return TasksState(
      status: status ?? this.status,
      tasks: tasks ?? this.tasks,
      errorMessage: errorMessage ?? this.errorMessage,
      categories: categories ?? this.categories,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      availableTags: availableTags ?? this.availableTags,
    );
  }

  @override
  List<Object?> get props => [
    status,
    tasks,
    errorMessage,
    categories,
    selectedCategoryId,
    availableTags,
  ];
}
