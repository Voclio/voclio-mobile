import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voclio_app/features/tasks/domain/entities/task_entity.dart';
import 'package:voclio_app/features/tasks/domain/usecases/create_task_use_case.dart';
import 'package:voclio_app/features/tasks/domain/usecases/delete_task_use_case.dart';
import 'package:voclio_app/features/tasks/domain/usecases/create_subtask_use_case.dart';
import 'package:voclio_app/features/tasks/domain/usecases/update_subtask_use_case.dart';
import 'package:voclio_app/features/tasks/domain/usecases/complete_task_use_case.dart';
import 'package:voclio_app/features/tasks/domain/usecases/get_all_tasks_use_case.dart';
import 'package:voclio_app/features/tasks/domain/usecases/get_task_use_case.dart';
import 'package:voclio_app/features/tasks/domain/usecases/update_task_use_case.dart';
import 'package:voclio_app/features/tasks/presentation/bloc/tasks_state.dart';

class TasksCubit extends Cubit<TasksState> {
  final GetAllTasksUseCase getAllTasksUseCase;
  final GetTaskUseCase getTaskUseCase;
  final CreateTaskUseCase createTaskUseCase;
  final UpdateTaskUseCase updateTaskUseCase;
  final DeleteTaskUseCase deletaTaskUseCase;
  final CompleteTaskUseCase completeTaskUseCase;
  final CreateSubtaskUseCase createSubtaskUseCase;
  final UpdateSubtaskUseCase updateSubtaskUseCase;

  TasksCubit({
    required this.deletaTaskUseCase,
    required this.updateTaskUseCase,
    required this.completeTaskUseCase,
    required this.createSubtaskUseCase,
    required this.updateSubtaskUseCase,
    required this.getAllTasksUseCase,
    required this.getTaskUseCase,
    required this.createTaskUseCase,
  }) : super(const TasksState());

  Future<void> getTasks() async {
    emit(state.copyWith(status: TasksStatus.loading));

    final result = await getAllTasksUseCase();
    if (isClosed) return;

    result.fold(
      (failure) {
        print('Error fetching tasks: ${failure.message}');
        emit(
          state.copyWith(
            status: TasksStatus.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (tasks) {
        print('Successfully fetched ${tasks.length} tasks');
        emit(state.copyWith(status: TasksStatus.success, tasks: tasks));
      },
    );
  }

  Future<void> addTask(TaskEntity task) async {
    emit(state.copyWith(status: TasksStatus.loading));
    final result = await createTaskUseCase(task);
    if (isClosed) return;

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: TasksStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (newTask) {
        // We refresh from server to get the real ID and proper formatting
        getTasks();
      },
    );
  }

  Future<void> updateTask(TaskEntity task) async {
    // 1. Optimistic UI Update
    final int index = state.tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      final updatedList = List<TaskEntity>.from(state.tasks);
      updatedList[index] = task;
      emit(state.copyWith(tasks: updatedList));
    }

    // 2. Call API
    final result = await updateTaskUseCase(task);

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: TasksStatus.failure,
            errorMessage: failure.message,
          ),
        );
        getTasks();
      },
      (successTask) {
        // successTask returned from server might have different structure/IDs
        final int index = state.tasks.indexWhere((t) => t.id == task.id);
        if (index != -1) {
          final updatedList = List<TaskEntity>.from(state.tasks);
          updatedList[index] = successTask;
          emit(state.copyWith(tasks: updatedList));
        }
      },
    );
  }

  Future<void> addSubtask(String taskId, String title) async {
    // 1. Optimistic UI update (optional, but good for UX)
    final int taskIndex = state.tasks.indexWhere((t) => t.id == taskId);
    if (taskIndex != -1) {
      final task = state.tasks[taskIndex];
      final tempSubtask = SubTask(
        id: 'temp-${DateTime.now().millisecondsSinceEpoch}',
        title: title,
      );
      final updatedTask = task.copyWith(
        subtasks: [...task.subtasks, tempSubtask],
      );

      final updatedTasks = List<TaskEntity>.from(state.tasks);
      updatedTasks[taskIndex] = updatedTask;
      emit(state.copyWith(tasks: updatedTasks));
    }

    final result = await createSubtaskUseCase(taskId, title, 0);

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: TasksStatus.failure,
            errorMessage: failure.message,
          ),
        );
        getTasks(); // Revert
      },
      (subtaskEntity) {
        // Refresh full task to get updated subtask list with server IDs
        getTasks();
      },
    );
  }

  Future<void> toggleSubtask(String taskId, SubTask subtask) async {
    // 1. Optimistic UI update
    final int taskIndex = state.tasks.indexWhere((t) => t.id == taskId);
    if (taskIndex != -1) {
      final task = state.tasks[taskIndex];
      final updatedSubtasks =
          task.subtasks.map((s) {
            if (s.id == subtask.id) {
              return s.copyWith(isDone: !s.isDone);
            }
            return s;
          }).toList();

      final updatedTasks = List<TaskEntity>.from(state.tasks);
      updatedTasks[taskIndex] = task.copyWith(subtasks: updatedSubtasks);
      emit(state.copyWith(tasks: updatedTasks));
    }

    // 2. Call API
    final result = await updateSubtaskUseCase(
      subtask.id,
      subtask.title,
      !subtask.isDone,
    );

    result.fold((failure) {
      emit(
        state.copyWith(
          status: TasksStatus.failure,
          errorMessage: failure.message,
        ),
      );
      getTasks(); // Revert on error
    }, (_) => null);
  }

  Future<void> deleteTask(String taskId) async {
    // 1. Optimistic Delete
    final updatedList = state.tasks.where((t) => t.id != taskId).toList();
    emit(state.copyWith(tasks: updatedList));

    // 2. Call API
    final result = await deletaTaskUseCase(taskId);

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: TasksStatus.failure,
            errorMessage: failure.message,
          ),
        );
        getTasks(); // Re-fetch on error
      },
      (_) => null, // Success
    );
  }

  Future<void> completeTask(String taskId) async {
    // 1. Optimistic UI Update
    final int index = state.tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      final updatedList = List<TaskEntity>.from(state.tasks);
      final task = updatedList[index];
      updatedList[index] = task.copyWith(isDone: !task.isDone);
      emit(state.copyWith(tasks: updatedList));
    }

    // 2. Call API
    final result = await completeTaskUseCase(taskId);

    result.fold((failure) {
      emit(
        state.copyWith(
          status: TasksStatus.failure,
          errorMessage: failure.message,
        ),
      );
      getTasks(); // Re-fetch to revert to server state
    }, (_) => null);
  }
}
