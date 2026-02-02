import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:voclio_app/features/tasks/domain/entities/task_entity.dart';
import 'package:voclio_app/features/tasks/presentation/bloc/tasks_state.dart';
import '../bloc/tasks_cubit.dart';

class TaskDetailScreen extends StatelessWidget {
  final TaskEntity task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    // We wrap in BlocBuilder to ensure UI updates if Subtasks change
    return BlocBuilder<TasksCubit, TasksState>(
      builder: (context, state) {
        // Find the specific task in the state to get the latest updates (e.g. subtask checks)
        // Fallback to the passed 'task' if not found (edge case)
        final currentTask = state.tasks.firstWhere(
          (t) => t.id == task.id,
          orElse: () => task,
        );

        final theme = Theme.of(context);
        // final isDark = theme.brightness == Brightness.dark;

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.share_outlined,
                  color: theme.colorScheme.onSurface,
                ),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.more_vert, color: theme.colorScheme.onSurface),
                onPressed: () {},
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10.h),

                // 1. Header (Title & Tags)
                _buildHeader(context, currentTask),

                SizedBox(height: 24.h),

                // 2. Due Date & Pin
                _buildDateSection(context, currentTask),

                SizedBox(height: 24.h),

                // 3. Description
                Text("Description", style: theme.textTheme.bodyMedium),
                SizedBox(height: 8.h),
                _buildContainer(
                  context,
                  child: Text(
                    currentTask.description ?? "No description provided.",
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontSize: 14.sp,
                      height: 1.5,
                      color: theme.colorScheme.onSurface.withOpacity(0.8),
                    ),
                  ),
                ),

                SizedBox(height: 24.h),

                // 4. Subtasks
                _buildSubtasksSection(context, currentTask),

                // 5. Related Note (Conditional)
                if (currentTask.relatedNoteId != null) ...[
                  SizedBox(height: 24.h),
                  Text("Related Note", style: theme.textTheme.bodyMedium),
                  SizedBox(height: 8.h),
                  RelatedNoteWIdget(context: context),
                ],

                SizedBox(height: 40.h),

                // 6. Action Buttons
                ActionButtonsTaskDetails(task: currentTask),

                SizedBox(height: 40.h),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- Helper Widgets ---

  Widget _buildHeader(BuildContext context, TaskEntity task) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Status Icon
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: theme.colorScheme.primary, width: 2),
              ),
              child: Icon(
                Icons.check,
                size: 16.sp,
                color: theme.colorScheme.primary,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                task.title,
                style: theme.textTheme.headlineSmall?.copyWith(fontSize: 20.sp),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            if (task.tags.isNotEmpty)
              _buildTagChip(
                context,
                Icons.label_outline,
                task.tags.first.label,
                null,
              ),
            SizedBox(width: 10.w),
            _buildTagChip(
              context,
              Icons.flag_outlined,
              "${task.priority.displayName} Priority",
              task.priority.color.withOpacity(0.2),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTagChip(
    BuildContext context,
    IconData icon,
    String label,
    Color? bgColor,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: bgColor ?? (isDark ? Colors.white10 : Colors.grey.shade100),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: theme.colorScheme.secondary),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSection(BuildContext context, TaskEntity task) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM d, h:mm a');

    return _buildContainer(
      context,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.calendar_today,
                  color: theme.colorScheme.primary,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 16.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Due Date",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 12.sp,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    dateFormat.format(task.date),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16.h),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: Icon(Icons.push_pin_outlined, size: 16.sp),
              label: const Text("Pin to Calendar"),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                side: BorderSide(
                  color: theme.colorScheme.secondary.withOpacity(0.3),
                ),
                foregroundColor: theme.colorScheme.onSurface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtasksSection(BuildContext context, TaskEntity task) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Subtasks",
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "${task.completedSubtasks}/${task.totalSubtasks}",
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
        SizedBox(height: 12.h),
        _buildContainer(
          context,
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              ...task.subtasks.map(
                (subtask) => Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
                      leading: InkWell(
                        onTap: () {
                          // Use dedicated toggleSubtask method
                          context.read<TasksCubit>().toggleSubtask(
                                task.id,
                                subtask,
                              );
                        },
                        child: Container(
                          width: 20.w,
                          height: 20.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color:
                                  subtask.isDone
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.secondary,
                            ),
                            color:
                                subtask.isDone
                                    ? theme.colorScheme.primary
                                    : Colors.transparent,
                          ),
                          child:
                              subtask.isDone
                                  ? Icon(
                                    Icons.check,
                                    size: 14.sp,
                                    color: Colors.white,
                                  )
                                  : null,
                        ),
                      ),
                      title: Text(
                        subtask.title,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: theme.colorScheme.onSurface.withOpacity(
                            subtask.isDone ? 0.5 : 1.0,
                          ),
                          decoration:
                              subtask.isDone
                                  ? TextDecoration.lineThrough
                                  : null,
                        ),
                      ),
                    ),
                    if (subtask != task.subtasks.last)
                      Divider(
                        height: 1,
                        color: theme.colorScheme.secondary.withOpacity(0.1),
                      ),
                  ],
                ),
              ),

              // Add Subtask Button
              InkWell(
                onTap: () {
                  // Logic to show dialog to add subtask
                  _showAddSubtaskDialog(context, task);
                },
                child: Padding(
                  padding: EdgeInsets.all(16.r),
                  child: Row(
                    children: [
                      Icon(
                        Icons.add,
                        size: 20.sp,
                        color: theme.colorScheme.secondary,
                      ),
                      SizedBox(width: 12.w),
                      Text("Add subtask", style: theme.textTheme.bodyMedium),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Generic container for cards
  Widget _buildContainer(
    BuildContext context, {
    required Widget child,
    EdgeInsetsGeometry? padding,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        border:
            isDark
                ? Border.all(color: Colors.white.withOpacity(0.05))
                : Border.all(color: Colors.grey.shade200),
        boxShadow:
            isDark
                ? []
                : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
      ),
      child: child,
    );
  }
}

class RelatedNoteWIdget extends StatelessWidget {
  const RelatedNoteWIdget({super.key, required this.context});

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color:
            isDark
                ? const Color(0xFF252538)
                : Colors.grey.shade50, // Slightly distinct bg
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.description,
                  color: Colors.blueAccent,
                  size: 18.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  "Math homework notes", // Dynamic in future
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            "Key formulas and concepts from today's lesson on quadratic equations...",
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium,
          ),
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: theme.colorScheme.primary.withOpacity(0.5),
                ),
                foregroundColor: theme.colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: const Text("View Note"),
            ),
          ),
        ],
      ),
    );
  }
}

class ActionButtonsTaskDetails extends StatelessWidget {
  const ActionButtonsTaskDetails({super.key, required this.task});

  final TaskEntity task;

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50.h,
          child: ElevatedButton(
            onPressed: () {
              // Logic to mark as complete
              context.read<TasksCubit>().completeTask(task.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFA5D6A7), // Soft Green
              foregroundColor: Colors.black87,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
            child: Text(
              task.isDone ? "Mark as Incomplete" : "Mark as Complete",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        SizedBox(height: 16.h),
        SizedBox(
          width: double.infinity,
          height: 50.h,
          child: ElevatedButton(
            onPressed: () {
              final cubit = context.read<TasksCubit>();
              Navigator.pop(context);
              cubit.deleteTask(task.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF9A9A), // Soft Red
              foregroundColor: Colors.black87,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
            child: const Text(
              "Delete Task",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}

void _showAddSubtaskDialog(BuildContext context, TaskEntity currentTask) {
  final theme = Theme.of(context);
  final controller = TextEditingController();
  // Capture the cubit to ensure we can use it inside the dialog logic
  final cubit = context.read<TasksCubit>();

  showDialog(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Text(
          "New Subtask",
          style: theme.textTheme.headlineSmall?.copyWith(fontSize: 18.sp),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: theme.textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: "What needs to be done?",
            hintStyle: TextStyle(
              color: theme.colorScheme.secondary.withOpacity(0.5),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: theme.colorScheme.primary.withOpacity(0.5),
              ),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: theme.colorScheme.primary),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              "Cancel",
              style: TextStyle(color: theme.colorScheme.secondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                // Use the dedicated addSubtask method
                cubit.addSubtask(currentTask.id, text);

                // 4. Close dialog
                Navigator.pop(dialogContext);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: const Text("Add"),
          ),
        ],
      );
    },
  );
}
