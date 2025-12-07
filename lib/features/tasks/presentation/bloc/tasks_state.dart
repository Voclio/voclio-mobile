import 'package:equatable/equatable.dart';
import 'package:voclio_app/features/tasks/domain/entities/task_entity.dart';

enum TasksStatus { initial, loading, success, failure }

class TasksState extends Equatable {
  final TasksStatus status;
  final List<TaskEntity> tasks;
  final String errorMessage;

  const TasksState({
    this.status = TasksStatus.initial,
    this.tasks = const [],
    this.errorMessage = '',
  });

  TasksState copyWith({
    TasksStatus? status,
    List<TaskEntity>? tasks,
    String? errorMessage,
  }) {
    return TasksState(
      status: status ?? this.status,
      tasks: tasks ?? this.tasks,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object> get props => [status, tasks, errorMessage];
}
