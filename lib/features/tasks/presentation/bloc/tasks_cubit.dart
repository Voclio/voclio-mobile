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
import 'package:voclio_app/features/tasks/domain/usecases/get_tasks_by_category_use_case.dart';
import 'package:voclio_app/features/tasks/domain/usecases/get_categories_use_case.dart';
import 'package:voclio_app/core/domain/usecases/get_tags_use_case.dart';
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
  final GetTasksByCategoryUseCase getTasksByCategoryUseCase;
  final GetCategoriesUseCase getCategoriesUseCase;
  final GetTagsUseCase getTagsUseCase;

  TasksCubit({
    required this.deletaTaskUseCase,
    required this.updateTaskUseCase,
    required this.completeTaskUseCase,
    required this.createSubtaskUseCase,
    required this.updateSubtaskUseCase,
    required this.getAllTasksUseCase,
    required this.getTaskUseCase,
    required this.createTaskUseCase,
    required this.getTasksByCategoryUseCase,
    required this.getCategoriesUseCase,
    required this.getTagsUseCase,
  }) : super(const TasksState());

  Future<void> init() async {
    await fetchTags();
    // await fetchCategories(); // Endpoint seems broken/missing on backend
    await getTasks();
  }

  Future<void> fetchCategories() async {
    final result = await getCategoriesUseCase();
    result.fold(
      (failure) => print('Failed to fetch categories: ${failure.message}'),
      (categories) => emit(state.copyWith(categories: categories)),
    );
  }

  Future<void> fetchTags() async {
    final result = await getTagsUseCase();
    result.fold(
      (failure) => print('Failed to fetch tags: ${failure.message}'),
      (tags) => emit(state.copyWith(availableTags: tags)),
    );
  }

  Future<void> getTasks() async {
    emit(state.copyWith(status: TasksStatus.loading));

    // If a tag is selected, fetch all and filter client-side (or refresh filter)
    if (state.selectedTagName != null) {
      await filterByTag(state.selectedTagName);
      return;
    }

    // If a category is selected, fetch by category
    if (state.selectedCategoryId != null) {
      await filterByCategory(state.selectedCategoryId);
      return;
    }

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

  Future<void> filterByCategory(String? categoryId) async {
    emit(
      state.copyWith(
        selectedCategoryId: () => categoryId,
        selectedTagName: () => null,
      ),
    );

    if (categoryId == null) {
      // Fetch all tasks
      // We manually call getAllTasksUseCase here to avoid infinite recursion since getTasks() checks selectedCategoryId
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
    } else {
      // Fetch specific category
      emit(state.copyWith(status: TasksStatus.loading));
      final result = await getTasksByCategoryUseCase(categoryId);
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
  }

  Future<void> filterByTag(String? tagName) async {
    emit(
      state.copyWith(
        selectedTagName: () => tagName,
        selectedCategoryId: () => null,
      ),
    );

    emit(state.copyWith(status: TasksStatus.loading));
    final result = await getAllTasksUseCase();

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: TasksStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (tasks) {
        if (tagName == null) {
          emit(state.copyWith(status: TasksStatus.success, tasks: tasks));
        } else {
          final filteredTasks =
              tasks.where((t) => t.tags.contains(tagName)).toList();
          emit(
            state.copyWith(status: TasksStatus.success, tasks: filteredTasks),
          );
        }
      },
    );
  }

  Future<void> addTask(TaskEntity task) async {
    // 1. Optimistic Update
    final currentTasks = state.tasks;
    // Add to top of list immediately
    emit(state.copyWith(tasks: [task, ...currentTasks]));

    final result = await createTaskUseCase(task);
    if (isClosed) return;

    result.fold(
      (failure) {
        // Revert on failure
        emit(
          state.copyWith(
            status: TasksStatus.failure,
            errorMessage: failure.message,
            tasks: currentTasks, // Revert to original list
          ),
        );
      },
      (newTask) {
        // Find the optimistic task and replace it.
        // We check by ID first, then by Title and Date if ID changed (server-assigned ID).
        final int index = state.tasks.indexWhere(
          (t) =>
              t.id == task.id ||
              (t.title == task.title &&
                  t.date.year == task.date.year &&
                  t.date.month == task.date.month &&
                  t.date.day == task.date.day),
        );

        if (index != -1) {
          final updatedList = List<TaskEntity>.from(state.tasks);

          // CRITICAL: Merge data to prevent flickering if server returns incomplete fields.
          // We prioritize server data but fallback to optimistic data for tags/title if server returns empty.
          final mergedTask = newTask.copyWith(
            tags: newTask.tags.isEmpty ? task.tags : newTask.tags,
            title:
                (newTask.title.isEmpty && task.title.isNotEmpty)
                    ? task.title
                    : newTask.title,
            description:
                (newTask.description == null || newTask.description!.isEmpty)
                    ? task.description
                    : newTask.description,
          );

          updatedList[index] = mergedTask;
          emit(state.copyWith(tasks: updatedList, status: TasksStatus.success));
        } else {
          // Fallback if not found
          getTasks();
        }
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
    // 1. Find the task
    final int taskIndex = state.tasks.indexWhere((t) => t.id == taskId);
    if (taskIndex == -1) return;

    final task = state.tasks[taskIndex];
    final tempId = 'temp-${DateTime.now().millisecondsSinceEpoch}';
    
    // 2. Optimistic UI update with temporary subtask
    final tempSubtask = SubTask(
      id: tempId,
      title: title,
      isDone: false,
    );
    final updatedTask = task.copyWith(
      subtasks: [...task.subtasks, tempSubtask],
    );

    final updatedTasks = List<TaskEntity>.from(state.tasks);
    updatedTasks[taskIndex] = updatedTask;
    emit(state.copyWith(tasks: updatedTasks));

    // 3. Call API
    final result = await createSubtaskUseCase(taskId, title, task.subtasks.length);

    result.fold(
      (failure) {
        // Revert by removing the temp subtask
        final revertedTask = task.copyWith(
          subtasks: task.subtasks.where((s) => s.id != tempId).toList(),
        );
        final revertedTasks = List<TaskEntity>.from(state.tasks);
        final idx = revertedTasks.indexWhere((t) => t.id == taskId);
        if (idx != -1) revertedTasks[idx] = revertedTask;
        
        emit(
          state.copyWith(
            status: TasksStatus.failure,
            errorMessage: failure.message,
            tasks: revertedTasks,
          ),
        );
      },
      (subtaskEntity) {
        // Replace temp subtask with real one from server
        final currentTasks = List<TaskEntity>.from(state.tasks);
        final idx = currentTasks.indexWhere((t) => t.id == taskId);
        if (idx != -1) {
          final currentTask = currentTasks[idx];
          final newSubtasks = currentTask.subtasks.map((s) {
            if (s.id == tempId) {
              return SubTask(
                id: subtaskEntity.id,
                title: subtaskEntity.title,
                isDone: subtaskEntity.completed,
              );
            }
            return s;
          }).toList();
          currentTasks[idx] = currentTask.copyWith(subtasks: newSubtasks);
          emit(state.copyWith(tasks: currentTasks, status: TasksStatus.success));
        }
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
      taskId,
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

  Future<void> toggleTaskStatus(TaskEntity task) async {
    // 1. Optimistic UI Update
    final int index = state.tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      final updatedList = List<TaskEntity>.from(state.tasks);
      // Toggle status
      final newTask = task.copyWith(isDone: !task.isDone);
      updatedList[index] = newTask;
      emit(state.copyWith(tasks: updatedList));
    }

    // 2. Call API using updateTask to persist the new isDone status
    final result = await updateTaskUseCase(task.copyWith(isDone: !task.isDone));

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
