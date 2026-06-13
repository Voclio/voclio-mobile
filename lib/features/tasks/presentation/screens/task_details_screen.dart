import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:voclio_app/core/common/dialogs/voclio_dialog.dart';
import 'package:voclio_app/core/enums/enums.dart';
import 'package:voclio_app/core/layout/main_layout.dart';
import 'package:voclio_app/core/routes/App_routes.dart';
import 'package:voclio_app/features/calendar/presentation/screens/monthly_calendar_screen.dart';
import 'package:voclio_app/core/utils/date_time_utils.dart';
import 'package:voclio_app/core/widgets/home_system/home_system_tokens.dart';
import 'package:voclio_app/core/widgets/home_system/home_system_widgets.dart';
import 'package:voclio_app/features/tasks/domain/entities/task_entity.dart';
import 'package:voclio_app/features/tasks/presentation/bloc/tasks_state.dart';
import 'package:voclio_app/features/tasks/presentation/widgets/add_task_buttom_sheet.dart';
import '../bloc/tasks_cubit.dart';
import 'package:voclio_app/core/icons/app_icons.dart';

class TaskDetailScreen extends StatefulWidget {
  final TaskEntity task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<TasksCubit>().loadSubtasks(
        widget.task.id,
        fallbackTask: widget.task,
      );
    });
  }

  TaskEntity _resolveTask(TasksState state, TaskEntity fallback) {
    for (final candidate in [...state.tasks, ...state.allTasks]) {
      if (candidate.id == fallback.id) {
        return candidate;
      }
    }
    return fallback;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TasksCubit, TasksState>(
      listenWhen: (previous, current) =>
          previous.errorMessage != current.errorMessage &&
          current.status == TasksStatus.failure,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.errorMessage),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: BlocBuilder<TasksCubit, TasksState>(
        builder: (context, state) {
          final currentTask = _resolveTask(state, widget.task);

        final theme = Theme.of(context);
        final isCompleted = currentTask.isDone;
        final isOverdue = DateTimeUtils.isOverdue(
          currentTask.date,
          isCompleted: isCompleted,
        );

        return Scaffold(
          backgroundColor: HomeSystemTokens.canvas,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Padding(
              padding: EdgeInsets.only(left: 8.w),
              child: HomeIconButton(
                icon: AppIcons.arrow_back_ios_new_rounded,
                color: HomeSystemTokens.inkSoft,
                onTap: () => Navigator.pop(context),
              ),
            ),
            leadingWidth: 56.w,
            actions: [
              HomeIconButton(
                icon: AppIcons.share_outlined,
                color: HomeSystemTokens.inkSoft,
                onTap: () => _shareTask(context, currentTask),
              ),
              SizedBox(width: 4.w),
              Padding(
                padding: EdgeInsets.only(right: 12.w),
                child: HomeIconButton(
                  icon: AppIcons.more_horiz_rounded,
                  color: HomeSystemTokens.inkSoft,
                  onTap: () => _showTaskOptions(context, currentTask),
                ),
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
      ),
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
            isCompleted ? AppIcons.check_circle_rounded : AppIcons.warning_amber_rounded,
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
                    AppIcons.check,
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
                AppIcons.label_rounded, 
                tagLabel, 
                tagBgColor,
                tagTextColor,
              ),
            _buildTagChip(
              context,
              AppIcons.flag_rounded,
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
    final localDue = DateTimeUtils.toLocal(task.date);
    final dateFormat = DateFormat('MMM d, yyyy');
    final timeFormat = DateFormat.jm();

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
                  isOverdue ? AppIcons.event_busy_rounded : AppIcons.calendar_today_rounded,
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
                      dateFormat.format(localDue),
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
                      AppIcons.access_time_rounded,
                      size: 16.sp,
                      color: theme.colorScheme.secondary,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      timeFormat.format(localDue),
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
              onPressed: () => _openTaskInCalendar(context, task),
              icon: Icon(AppIcons.push_pin_outlined, size: 16.sp),
              label: const Text("View in Calendar"),
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
              AppIcons.description_outlined,
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
                      AppIcons.notes_rounded,
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
                  AppIcons.checklist_rounded,
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
                                  AppIcons.check,
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
                            AppIcons.add,
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
    return HomeSectionCard(
      padding: padding ?? EdgeInsets.all(16.r),
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

    return HomeSectionCard(
      padding: EdgeInsets.all(16.r),
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
                  AppIcons.description,
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
            onPressed: () async {
              await context.read<TasksCubit>().toggleTaskStatus(task);
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            icon: Icon(
              isCompleted ? AppIcons.refresh_rounded : AppIcons.check_circle_outline_rounded,
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
            onPressed: () => _openEditTask(context, task),
            icon: Icon(AppIcons.edit_outlined, size: 20.sp),
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
            onPressed: () => _showDeleteTaskConfirmation(context, task),
            icon: Icon(AppIcons.delete_outline_rounded, size: 20.sp),
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
  
}

void _openTaskInCalendar(BuildContext context, TaskEntity task) {
  MonthlyCalendarScreen.jumpTo(task.date);

  if (MainLayout.goToTab(2, calendarDate: task.date)) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Showing ${DateFormat('MMM d').format(task.date)} in Calendar',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
    return;
  }

  context.go(AppRouter.home);
  WidgetsBinding.instance.addPostFrameCallback((_) {
    MainLayout.goToTab(2, calendarDate: task.date);
  });
}

void _showDeleteTaskConfirmation(BuildContext context, TaskEntity task) {
  final cubit = context.read<TasksCubit>();

  VoclioDialog.showConfirm(
    context: context,
    title: 'Delete Task?',
    message:
        'This action cannot be undone. Are you sure you want to delete "${task.title}"?',
    confirmText: 'Delete',
    cancelText: 'Cancel',
    onConfirm: () {
      Navigator.pop(context);
      cubit.deleteTask(task.id);
    },
  );
}

String _priorityLabel(TaskPriority priority) {
  return switch (priority) {
    TaskPriority.high => 'High',
    TaskPriority.medium => 'Medium',
    TaskPriority.low => 'Low',
    TaskPriority.none => 'None',
  };
}

Future<void> _shareTask(BuildContext context, TaskEntity task) async {
  final dateFormat = DateFormat('MMM d, yyyy • h:mm a');
  final buffer = StringBuffer()
    ..writeln(task.title)
    ..writeln('Due: ${dateFormat.format(task.date)}')
    ..writeln('Priority: ${_priorityLabel(task.priority)}')
    ..writeln('Status: ${task.isDone ? 'Completed' : 'Pending'}');

  if (task.description != null && task.description!.trim().isNotEmpty) {
    buffer.writeln('\n${task.description!.trim()}');
  }

  buffer.writeln('\nShared from Voclio');

  await Share.share(buffer.toString().trim());
}

void _openEditTask(BuildContext context, TaskEntity task) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider.value(
      value: context.read<TasksCubit>(),
      child: AddTaskBottomSheet(taskToEdit: task),
    ),
  );
}

void _showTaskOptions(BuildContext context, TaskEntity task) {
  final theme = Theme.of(context);

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return Container(
        margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h + MediaQuery.paddingOf(sheetContext).bottom),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 12.h),
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              _TaskOptionTile(
                icon: AppIcons.edit_outlined,
                label: 'Edit Task',
                onTap: () {
                  Navigator.pop(sheetContext);
                  _openEditTask(context, task);
                },
              ),
              _TaskOptionTile(
                icon: task.isDone
                    ? AppIcons.refresh_rounded
                    : AppIcons.check_circle_outline_rounded,
                label: task.isDone ? 'Mark as Incomplete' : 'Mark as Complete',
                onTap: () {
                  Navigator.pop(sheetContext);
                  context.read<TasksCubit>().toggleTaskStatus(task);
                },
              ),
              _TaskOptionTile(
                icon: AppIcons.calendar_month_outlined,
                label: 'Open in Calendar',
                onTap: () {
                  Navigator.pop(sheetContext);
                  _openTaskInCalendar(context, task);
                },
              ),
              _TaskOptionTile(
                icon: AppIcons.delete_outline_rounded,
                label: 'Delete Task',
                color: HomeSystemTokens.coral,
                onTap: () {
                  Navigator.pop(sheetContext);
                  _showDeleteTaskConfirmation(context, task);
                },
              ),
              SizedBox(height: 8.h),
            ],
          ),
        ),
      );
    },
  );
}

class _TaskOptionTile extends StatelessWidget {
  const _TaskOptionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final itemColor = color ?? HomeSystemTokens.ink;

    return ListTile(
      leading: Icon(icon, color: itemColor),
      title: Text(
        label,
        style: TextStyle(
          color: itemColor,
          fontWeight: FontWeight.w600,
          fontSize: 15.sp,
        ),
      ),
      onTap: onTap,
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
