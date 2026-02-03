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
        final isDark = theme.brightness == Brightness.dark;
        final isCompleted = currentTask.isDone;
        final isOverdue = !isCompleted && currentTask.date.isBefore(DateTime.now());

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(Icons.arrow_back_ios_new_rounded, 
                  color: theme.colorScheme.onSurface,
                  size: 18.sp,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.share_outlined,
                    color: theme.colorScheme.onSurface,
                    size: 18.sp,
                  ),
                ),
                onPressed: () {},
              ),
              SizedBox(width: 4.w),
              IconButton(
                icon: Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(Icons.more_horiz_rounded, 
                    color: theme.colorScheme.onSurface,
                    size: 18.sp,
                  ),
                ),
                onPressed: () {},
              ),
              SizedBox(width: 8.w),
            ],
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10.h),
                
                // Status Banner
                if (isCompleted || isOverdue)
                  _buildStatusBanner(context, isCompleted, isOverdue),
                if (isCompleted || isOverdue)
                  SizedBox(height: 16.h),

                // 1. Header (Title & Tags)
                _buildHeader(context, currentTask, state),

                SizedBox(height: 24.h),

                // 2. Due Date & Pin
                _buildDateSection(context, currentTask, isOverdue),

                SizedBox(height: 24.h),

                // 3. Description
                _buildDescriptionSection(context, currentTask),

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
  
  Widget _buildStatusBanner(BuildContext context, bool isCompleted, bool isOverdue) {
    final theme = Theme.of(context);
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: isCompleted 
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isCompleted 
              ? Colors.green.withOpacity(0.3)
              : Colors.red.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isCompleted ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
            color: isCompleted ? Colors.green : Colors.red,
            size: 24.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCompleted ? 'Task Completed' : 'Overdue Task',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isCompleted ? Colors.green.shade700 : Colors.red.shade700,
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  isCompleted 
                      ? 'Great job! You finished this task.'
                      : 'This task is past its due date.',
                  style: TextStyle(
                    color: isCompleted ? Colors.green.shade600 : Colors.red.shade600,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, TaskEntity task, TasksState state) {
    final theme = Theme.of(context);
    final isCompleted = task.isDone;

    // Find tag entity for color
    Color? tagBgColor;
    Color? tagTextColor;
    String tagLabel = "";

    if (task.tags.isNotEmpty) {
      tagLabel = task.tags.first;
      try {
        final tagEntity = state.availableTags.firstWhere(
          (t) => t.name == tagLabel,
        );
        final hex = tagEntity.color.replaceAll('#', '');
        final baseColor = Color(int.parse('FF$hex', radix: 16));
        tagBgColor = baseColor.withOpacity(0.15);
        tagTextColor = baseColor;
      } catch (_) {
        tagBgColor = theme.colorScheme.primary.withOpacity(0.1);
        tagTextColor = theme.colorScheme.primary;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title with completion indicator
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isCompleted)
              Padding(
                padding: EdgeInsets.only(top: 6.h, right: 12.w),
                child: Container(
                  padding: EdgeInsets.all(4.r),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16.sp,
                  ),
                ),
              ),
            Expanded(
              child: Text(
                task.title,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 28.sp,
                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                  decorationColor: Colors.green,
                  color: isCompleted 
                      ? theme.colorScheme.onSurface.withOpacity(0.6)
                      : theme.colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        
        // Tags and Priority chips
        Wrap(
          spacing: 10.w,
          runSpacing: 8.h,
          children: [
            if (task.tags.isNotEmpty)
              _buildTagChip(
                context, 
                Icons.label_rounded, 
                tagLabel, 
                tagBgColor,
                tagTextColor,
              ),
            _buildTagChip(
              context,
              Icons.flag_rounded,
              "${task.priority.displayName}",
              task.priority.color.withOpacity(0.15),
              task.priority.color,
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
    Color? iconColor,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: bgColor ?? (isDark ? Colors.white10 : Colors.grey.shade100),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon, 
            size: 16.sp, 
            color: iconColor ?? theme.colorScheme.secondary,
          ),
          SizedBox(width: 8.w),
          Text(
            label,
            style: TextStyle(
              color: iconColor ?? theme.colorScheme.onSurface,
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSection(BuildContext context, TaskEntity task, bool isOverdue) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');

    return _buildContainer(
      context,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: isOverdue 
                      ? Colors.red.withOpacity(0.1)
                      : theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(
                  isOverdue ? Icons.event_busy_rounded : Icons.calendar_today_rounded,
                  color: isOverdue ? Colors.red : theme.colorScheme.primary,
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Due Date",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.secondary,
                        fontSize: 12.sp,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      dateFormat.format(task.date),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isOverdue ? Colors.red : null,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: theme.colorScheme.secondary.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 16.sp,
                      color: theme.colorScheme.secondary,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      timeFormat.format(task.date),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13.sp,
                      ),
                    ),
                  ],
                ),
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
                  color: theme.colorScheme.primary.withOpacity(0.3),
                ),
                foregroundColor: theme.colorScheme.primary,
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
  
  Widget _buildDescriptionSection(BuildContext context, TaskEntity task) {
    final theme = Theme.of(context);
    final hasDescription = task.description != null && task.description!.isNotEmpty;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.description_outlined,
              size: 20.sp,
              color: theme.colorScheme.primary,
            ),
            SizedBox(width: 8.w),
            Text(
              "Description",
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        _buildContainer(
          context,
          child: hasDescription
              ? Text(
                  task.description!,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontSize: 14.sp,
                    height: 1.6,
                    color: theme.colorScheme.onSurface.withOpacity(0.85),
                  ),
                )
              : Row(
                  children: [
                    Icon(
                      Icons.notes_rounded,
                      color: theme.colorScheme.secondary.withOpacity(0.5),
                      size: 20.sp,
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      "No description provided",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.secondary.withOpacity(0.7),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildSubtasksSection(BuildContext context, TaskEntity task) {
    final theme = Theme.of(context);
    final hasSubtasks = task.subtasks.isNotEmpty;
    final progress = task.totalSubtasks > 0 
        ? task.completedSubtasks / task.totalSubtasks 
        : 0.0;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.checklist_rounded,
                  size: 20.sp,
                  color: theme.colorScheme.primary,
                ),
                SizedBox(width: 8.w),
                Text(
                  "Subtasks",
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: progress == 1.0 
                    ? Colors.green.withOpacity(0.15)
                    : theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                "${task.completedSubtasks}/${task.totalSubtasks}",
                style: TextStyle(
                  color: progress == 1.0 
                      ? Colors.green
                      : theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12.sp,
                ),
              ),
            ),
          ],
        ),
        
        // Progress bar
        if (hasSubtasks) ...[
          SizedBox(height: 12.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(
                progress == 1.0 ? Colors.green : theme.colorScheme.primary,
              ),
              minHeight: 6.h,
            ),
          ),
        ],
        
        SizedBox(height: 12.h),
        _buildContainer(
          context,
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              ...task.subtasks.asMap().entries.map((entry) {
                final index = entry.key;
                final subtask = entry.value;
                final isTemp = subtask.id.startsWith('temp-');
                
                return Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 4.h,
                      ),
                      leading: GestureDetector(
                        onTap: isTemp ? null : () {
                          context.read<TasksCubit>().toggleSubtask(
                            task.id,
                            subtask,
                          );
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 22.w,
                          height: 22.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: subtask.isDone
                                  ? Colors.green
                                  : theme.colorScheme.secondary.withOpacity(0.4),
                              width: 2,
                            ),
                            color: subtask.isDone
                                ? Colors.green
                                : Colors.transparent,
                          ),
                          child: subtask.isDone
                              ? Icon(
                                  Icons.check,
                                  size: 14.sp,
                                  color: Colors.white,
                                )
                              : isTemp
                                  ? SizedBox(
                                      width: 12.w,
                                      height: 12.h,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: theme.colorScheme.primary,
                                      ),
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
                              subtask.isDone ? TextDecoration.lineThrough : null,
                          decorationColor: Colors.green,
                          fontWeight: subtask.isDone ? FontWeight.normal : FontWeight.w500,
                        ),
                      ),
                      trailing: isTemp
                          ? Text(
                              'Saving...',
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: theme.colorScheme.secondary,
                                fontStyle: FontStyle.italic,
                              ),
                            )
                          : null,
                    ),
                    if (index < task.subtasks.length - 1)
                      Divider(
                        height: 1,
                        indent: 16.w,
                        endIndent: 16.w,
                        color: theme.colorScheme.secondary.withOpacity(0.1),
                      ),
                  ],
                );
              }),

              // Divider before add button
              if (hasSubtasks)
                Divider(
                  height: 1,
                  color: theme.colorScheme.secondary.withOpacity(0.1),
                ),

              // Add Subtask Button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    _showAddSubtaskDialog(context, task);
                  },
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16.r),
                    bottomRight: Radius.circular(16.r),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16.r),
                    child: Row(
                      children: [
                        Container(
                          width: 22.w,
                          height: 22.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: theme.colorScheme.primary.withOpacity(0.5),
                              width: 2,
                              strokeAlign: BorderSide.strokeAlignCenter,
                            ),
                          ),
                          child: Icon(
                            Icons.add,
                            size: 14.sp,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        SizedBox(width: 14.w),
                        Text(
                          "Add subtask",
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w500,
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
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
    final theme = Theme.of(context);
    final isCompleted = task.isDone;
    
    return Column(
      children: [
        // Complete/Incomplete Button
        SizedBox(
          width: double.infinity,
          height: 54.h,
          child: ElevatedButton.icon(
            onPressed: () {
              context.read<TasksCubit>().toggleTaskStatus(task);
              Navigator.pop(context);
            },
            icon: Icon(
              isCompleted ? Icons.refresh_rounded : Icons.check_circle_outline_rounded,
              size: 22.sp,
            ),
            label: Text(
              isCompleted ? "Mark as Incomplete" : "Mark as Complete",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15.sp,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: isCompleted 
                  ? Colors.orange.shade100
                  : Colors.green.shade100,
              foregroundColor: isCompleted 
                  ? Colors.orange.shade800
                  : Colors.green.shade800,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
          ),
        ),
        SizedBox(height: 12.h),
        
        // Edit Button
        SizedBox(
          width: double.infinity,
          height: 54.h,
          child: OutlinedButton.icon(
            onPressed: () {
              // TODO: Implement edit functionality
            },
            icon: Icon(Icons.edit_outlined, size: 20.sp),
            label: Text(
              "Edit Task",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15.sp,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.primary,
              side: BorderSide(
                color: theme.colorScheme.primary.withOpacity(0.3),
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
          ),
        ),
        SizedBox(height: 12.h),
        
        // Delete Button
        SizedBox(
          width: double.infinity,
          height: 54.h,
          child: ElevatedButton.icon(
            onPressed: () {
              _showDeleteConfirmation(context);
            },
            icon: Icon(Icons.delete_outline_rounded, size: 20.sp),
            label: Text(
              "Delete Task",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15.sp,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade50,
              foregroundColor: Colors.red.shade700,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  void _showDeleteConfirmation(BuildContext context) {
    final theme = Theme.of(context);
    final cubit = context.read<TasksCubit>();
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.red.shade400,
              size: 28.sp,
            ),
            SizedBox(width: 12.w),
            const Text('Delete Task?'),
          ],
        ),
        content: Text(
          'This action cannot be undone. Are you sure you want to delete "${task.title}"?',
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: TextStyle(color: theme.colorScheme.secondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pop(context);
              cubit.deleteTask(task.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
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
