import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voclio_app/features/tasks/domain/entities/task_entity.dart';
import 'package:voclio_app/features/tasks/domain/usecases/create_task_use_case.dart';
import 'package:voclio_app/features/tasks/domain/usecases/delete_task_use_case.dart';
import 'package:voclio_app/features/tasks/domain/usecases/create_subtask_use_case.dart';
import 'package:voclio_app/features/tasks/domain/usecases/get_subtasks_use_case.dart';
import 'package:voclio_app/features/tasks/domain/usecases/update_subtask_use_case.dart';
import 'package:voclio_app/features/tasks/domain/usecases/complete_task_use_case.dart';
import 'package:voclio_app/features/tasks/domain/usecases/get_all_tasks_use_case.dart';
import 'package:voclio_app/features/tasks/domain/usecases/get_task_use_case.dart';
import 'package:voclio_app/features/tasks/domain/usecases/update_task_use_case.dart';
import 'package:voclio_app/features/tasks/domain/usecases/get_tasks_by_category_use_case.dart';
import 'package:voclio_app/features/tasks/domain/usecases/get_categories_use_case.dart';
import 'package:voclio_app/core/domain/usecases/get_tags_use_case.dart';
import 'package:voclio_app/core/di/injection_container.dart';
import 'package:voclio_app/features/calendar/presentation/bloc/calendar_cubit.dart';
import 'package:voclio_app/features/tasks/presentation/bloc/tasks_state.dart';
import 'package:voclio_app/features/widget_config/data/services/home_screen_widget_service.dart';

class TasksCubit extends Cubit<TasksState> {
  final GetAllTasksUseCase getAllTasksUseCase;
  final GetTaskUseCase getTaskUseCase;
  final CreateTaskUseCase createTaskUseCase;
  final UpdateTaskUseCase updateTaskUseCase;
  final DeleteTaskUseCase deletaTaskUseCase;
  final CompleteTaskUseCase completeTaskUseCase;
  final CreateSubtaskUseCase createSubtaskUseCase;
  final GetSubtasksUseCase getSubtasksUseCase;
  final UpdateSubtaskUseCase updateSubtaskUseCase;
  final GetTasksByCategoryUseCase getTasksByCategoryUseCase;
  final GetCategoriesUseCase getCategoriesUseCase;
  final GetTagsUseCase getTagsUseCase;

  TasksCubit({
    required this.deletaTaskUseCase,
    required this.updateTaskUseCase,
    required this.completeTaskUseCase,
    required this.createSubtaskUseCase,
    required this.getSubtasksUseCase,
    required this.updateSubtaskUseCase,
    required this.getAllTasksUseCase,
    required this.getTaskUseCase,
    required this.createTaskUseCase,
    required this.getTasksByCategoryUseCase,
    required this.getCategoriesUseCase,
    required this.getTagsUseCase,
  }) : super(const TasksState());

  void _refreshCalendarForDate(DateTime date) {
    try {
      getIt<CalendarCubit>().loadMonth(date.year, date.month, force: true);
    } catch (_) {}
  }

  Future<void> init({bool force = false}) async {
    if (!force &&
        state.status == TasksStatus.success &&
        state.tasks.isNotEmpty) {
      return;
    }
    if (!force && state.status == TasksStatus.loading) return;

    emit(state.copyWith(status: TasksStatus.loading));

    final tagsResult = getTagsUseCase();
    final tasksResult = getAllTasksUseCase();

    final tags = await tagsResult;
    final tasks = await tasksResult;
    if (isClosed) return;

    tags.fold(
      (failure) => print('Failed to fetch tags: ${failure.message}'),
      (tagList) => emit(state.copyWith(availableTags: tagList)),
    );

    tasks.fold(
      (failure) {
        emit(
          state.copyWith(
            status: TasksStatus.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (taskList) {
        emit(
          state.copyWith(
            status: TasksStatus.success,
            tasks: taskList,
            allTasks: taskList,
          ),
        );
        HomeScreenWidgetService.syncTasks(taskList);
      },
    );
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
        emit(
          state.copyWith(
            status: TasksStatus.success,
            tasks: tasks,
            allTasks: tasks,
          ),
        );
        // Update home screen widget with today's tasks
        HomeScreenWidgetService.syncTasks(tasks);
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
          emit(
            state.copyWith(
              status: TasksStatus.success,
              tasks: tasks,
              allTasks: tasks,
            ),
          );
        } else {
          final filteredTasks =
              tasks.where((t) => t.tags.contains(tagName)).toList();
          emit(
            state.copyWith(
              status: TasksStatus.success,
              tasks: filteredTasks,
              allTasks: tasks,
            ),
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
          _refreshCalendarForDate(mergedTask.date);
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
          _refreshCalendarForDate(successTask.date);
        }
      },
    );
  }

  Future<void> loadSubtasks(String taskId, {TaskEntity? fallbackTask}) async {
    final result = await getSubtasksUseCase(taskId);

    result.fold((_) {}, (subtaskEntities) {
      if (isClosed) return;

      final subtasks =
          subtaskEntities
              .map(
                (subtask) => SubTask(
                  id: subtask.id,
                  title: subtask.title,
                  isDone: subtask.completed,
                ),
              )
              .toList();

      final tasks = _mergeSubtasksIntoTaskList(state.tasks, taskId, subtasks);
      final allTasks = _mergeSubtasksIntoTaskList(
        state.allTasks,
        taskId,
        subtasks,
      );

      if (_containsTask(tasks, taskId) || _containsTask(allTasks, taskId)) {
        emit(state.copyWith(tasks: tasks, allTasks: allTasks));
        return;
      }

      if (fallbackTask != null) {
        final enrichedTask = fallbackTask.copyWith(subtasks: subtasks);
        emit(
          state.copyWith(
            allTasks: [...state.allTasks, enrichedTask],
          ),
        );
      }
    });
  }

  bool _containsTask(List<TaskEntity> source, String taskId) {
    return source.any((task) => task.id == taskId);
  }

  List<TaskEntity> _mergeSubtasksIntoTaskList(
    List<TaskEntity> source,
    String taskId,
    List<SubTask> subtasks,
  ) {
    final index = source.indexWhere((task) => task.id == taskId);
    if (index == -1) return source;

    final updated = List<TaskEntity>.from(source);
    updated[index] = source[index].copyWith(subtasks: subtasks);
    return updated;
  }

  Future<void> addSubtask(String taskId, String title) async {
    final task = _findTask(taskId);
    if (task == null) return;

    final tempId = 'temp-${DateTime.now().millisecondsSinceEpoch}';
    final tempSubtask = SubTask(id: tempId, title: title, isDone: false);
    final optimisticSubtasks = [...task.subtasks, tempSubtask];

    emit(
      state.copyWith(
        tasks: _mergeSubtasksIntoTaskList(state.tasks, taskId, optimisticSubtasks),
        allTasks: _mergeSubtasksIntoTaskList(
          state.allTasks,
          taskId,
          optimisticSubtasks,
        ),
      ),
    );

    final result = await createSubtaskUseCase(
      taskId,
      title,
      task.subtasks.length,
    );

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: TasksStatus.failure,
            errorMessage: failure.message,
            tasks: _mergeSubtasksIntoTaskList(
              state.tasks,
              taskId,
              task.subtasks,
            ),
            allTasks: _mergeSubtasksIntoTaskList(
              state.allTasks,
              taskId,
              task.subtasks,
            ),
          ),
        );
      },
      (subtaskEntity) {
        final currentTask = _findTask(taskId);
        if (currentTask == null) return;

        final newSubtasks =
            currentTask.subtasks.map((s) {
              if (s.id == tempId) {
                return SubTask(
                  id: subtaskEntity.id,
                  title: subtaskEntity.title,
                  isDone: subtaskEntity.completed,
                );
              }
              return s;
            }).toList();

        emit(
          state.copyWith(
            status: TasksStatus.success,
            tasks: _mergeSubtasksIntoTaskList(state.tasks, taskId, newSubtasks),
            allTasks: _mergeSubtasksIntoTaskList(
              state.allTasks,
              taskId,
              newSubtasks,
            ),
          ),
        );
        _refreshCalendarForDate(task.date);
      },
    );
  }

  TaskEntity? _findTask(String taskId) {
    for (final task in [...state.tasks, ...state.allTasks]) {
      if (task.id == taskId) return task;
    }
    return null;
  }

  Future<void> toggleSubtask(String taskId, SubTask subtask) async {
    final int taskIndex = state.tasks.indexWhere((t) => t.id == taskId);
    final previousSubtasks =
        taskIndex != -1 ? state.tasks[taskIndex].subtasks : const <SubTask>[];

    // 1. Optimistic UI update
    if (taskIndex != -1) {
      final task = state.tasks[taskIndex];
      final updatedSubtasks =
          task.subtasks.map((s) {
            if (s.id == subtask.id) {
              return s.copyWith(isDone: !s.isDone);
            }
            return s;
          }).toList();

      final updatedTasks = _mergeSubtasksIntoTaskList(
        state.tasks,
        taskId,
        updatedSubtasks,
      );
      final updatedAllTasks = _mergeSubtasksIntoTaskList(
        state.allTasks,
        taskId,
        updatedSubtasks,
      );
      emit(state.copyWith(tasks: updatedTasks, allTasks: updatedAllTasks));
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
          tasks: _mergeSubtasksIntoTaskList(
            state.tasks,
            taskId,
            previousSubtasks,
          ),
          allTasks: _mergeSubtasksIntoTaskList(
            state.allTasks,
            taskId,
            previousSubtasks,
          ),
        ),
      );
    }, (_) {
      final parentTask = _findTask(taskId);
      if (parentTask != null) {
        _refreshCalendarForDate(parentTask.date);
      }
    });
  }

  Future<void> deleteTask(String taskId) async {
    final deletedTask = _findTask(taskId);

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
      (_) {
        if (deletedTask != null) {
          _refreshCalendarForDate(deletedTask.date);
        }
      },
    );
  }

  Future<void> toggleTaskStatus(TaskEntity task) async {
    final markComplete = !task.isDone;
    final optimisticTask = task.copyWith(isDone: markComplete);
    _replaceTaskInState(optimisticTask);

    final result = markComplete
        ? await completeTaskUseCase(task.id)
        : await updateTaskUseCase(task.copyWith(isDone: false));

    result.fold((failure) {
      emit(
        state.copyWith(
          status: TasksStatus.failure,
          errorMessage: failure.message,
        ),
      );
      getTasks();
    }, (_) => _refreshCalendarForDate(task.date));
  }

  void _replaceTaskInState(TaskEntity updatedTask) {
    emit(
      state.copyWith(
        tasks: _replaceTaskInList(state.tasks, updatedTask),
        allTasks: _replaceTaskInList(state.allTasks, updatedTask),
      ),
    );
  }

  List<TaskEntity> _replaceTaskInList(
    List<TaskEntity> list,
    TaskEntity updatedTask,
  ) {
    final index = list.indexWhere((t) => t.id == updatedTask.id);
    if (index == -1) return list;
    final copy = List<TaskEntity>.from(list);
    copy[index] = updatedTask;
    return copy;
  }
}
