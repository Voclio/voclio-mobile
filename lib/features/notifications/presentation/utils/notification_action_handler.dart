import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:voclio_app/core/routes/App_routes.dart';
import 'package:voclio_app/features/notifications/domain/entities/notification_entity.dart';
import 'package:voclio_app/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:voclio_app/features/tasks/domain/entities/task_entity.dart';
import 'package:voclio_app/features/tasks/domain/usecases/get_task_use_case.dart';
import 'package:voclio_app/features/tasks/presentation/bloc/tasks_cubit.dart';
import 'package:voclio_app/features/tasks/presentation/screens/task_details_screen.dart';

class NotificationActionHandler {
  NotificationActionHandler._();

  static Future<void> handleTap(
    BuildContext context,
    NotificationEntity notification,
  ) async {
    final cubit = context.read<NotificationsCubit>();
    if (!notification.isRead) {
      cubit.markAsRead(notification.id);
    }

    if (!context.mounted) return;

    switch (notification.type.toLowerCase()) {
      case 'task':
        await _openTask(context, notification);
      case 'reminder':
        await context.push(AppRouter.reminders);
      case 'achievement':
        await context.push(AppRouter.achievements);
      case 'system':
        await context.push(AppRouter.settings);
      default:
        break;
    }
  }

  static Future<void> _openTask(
    BuildContext context,
    NotificationEntity notification,
  ) async {
    final relatedId = notification.relatedId;
    if (relatedId == null) {
      _showMessage(context, 'This notification is not linked to a task.');
      return;
    }

    final taskId = relatedId.toString();
    final tasksCubit = GetIt.I<TasksCubit>();
    TaskEntity? task = _findTaskInState(tasksCubit, taskId);

    task ??= await GetIt.I<GetTaskUseCase>()(taskId);

    if (!context.mounted) return;

    if (task == null) {
      _showMessage(context, 'Task not found. It may have been deleted.');
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: tasksCubit,
          child: TaskDetailScreen(task: task!),
        ),
      ),
    );
  }

  static TaskEntity? _findTaskInState(TasksCubit cubit, String taskId) {
    final source =
        cubit.state.allTasks.isNotEmpty ? cubit.state.allTasks : cubit.state.tasks;
    for (final task in source) {
      if (task.id == taskId) {
        return task;
      }
    }
    return null;
  }

  static void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
