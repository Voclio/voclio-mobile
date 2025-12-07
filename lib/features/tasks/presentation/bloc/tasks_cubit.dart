import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voclio_app/features/tasks/domain/entities/task_entity.dart';
import 'package:voclio_app/features/tasks/domain/usecases/create_task_use_case.dart';
import 'package:voclio_app/features/tasks/domain/usecases/delete_task_use_case.dart';
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

  TasksCubit({
    required this.deletaTaskUseCase,
    required this.updateTaskUseCase,
    required this.getAllTasksUseCase,
    required this.getTaskUseCase,
    required this.createTaskUseCase,
  }) : super(const TasksState());

  Future<void> getTasks() async {
    emit(state.copyWith(status: TasksStatus.loading));

    final result = await getAllTasksUseCase();

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: TasksStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (tasks) =>
          emit(state.copyWith(status: TasksStatus.success, tasks: tasks)),
    );
  }

  Future<void> addTask(TaskEntity task) async {
    // Optional: emit loading if you want a spinner on the button
    // emit(state.copyWith(status: TasksStatus.loading));

    final result = await createTaskUseCase(task);

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: TasksStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (newTask) {
        final updatedList = List<TaskEntity>.from(state.tasks)..add(newTask);
        emit(state.copyWith(status: TasksStatus.success, tasks: updatedList));
      },
    );
  }

  Future<void> updateTask(TaskEntity task) async {
    // 1. Optimistic UI Update (Update screen instantly)
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
        // Revert or show error
        emit(
          state.copyWith(
            status: TasksStatus.failure,
            errorMessage: failure.message,
          ),
        );
        getTasks(); // Re-fetch data to sync with server
      },
      (successTask) {
        // success state already active via optimistic update
      },
    );
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
}
