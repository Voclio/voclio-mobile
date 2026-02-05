import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:voclio_app/features/tasks/presentation/bloc/tasks_cubit.dart';
import 'package:voclio_app/features/tasks/presentation/bloc/tasks_state.dart';
import 'package:voclio_app/features/tasks/domain/entities/task_entity.dart' as task_entities;
import 'package:voclio_app/features/notes/presentation/bloc/notes_cubit.dart';
import 'package:voclio_app/features/notes/presentation/bloc/note_state.dart';
import 'package:voclio_app/features/notes/domain/entities/note_entity.dart' as note_entities;
import '../../domain/entities/widget_preference.dart';
import '../bloc/widget_config_cubit.dart';
import '../bloc/widget_config_state.dart';

/// Container widget that displays all enabled home widgets
class HomeWidgetsContainer extends StatelessWidget {
  final Function(int)? onTabChange;

  const HomeWidgetsContainer({super.key, this.onTabChange});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WidgetConfigCubit, WidgetConfigState>(
      builder: (context, state) {
        if (state.status == WidgetConfigStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        final enabledWidgets = state.enabledWidgets;
        if (enabledWidgets.isEmpty) {
          return _buildEmptyState(context);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...enabledWidgets.asMap().entries.map((entry) {
              final index = entry.key;
              final config = entry.value;
              return Padding(
                padding: EdgeInsets.only(bottom: 16.h),
                child: _buildWidget(context, config)
                    .animate()
                    .fadeIn(delay: Duration(milliseconds: 100 * index))
                    .slideY(begin: 0.1, delay: Duration(milliseconds: 100 * index)),
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(
            Icons.widgets_outlined,
            size: 48.sp,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 12.h),
          Text(
            'No widgets enabled',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Go to settings to customize your home screen',
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildWidget(BuildContext context, WidgetConfig config) {
    switch (config.type) {
      case WidgetType.todayTasks:
        return TodayTasksWidget(onViewAll: () => onTabChange?.call(1));
      case WidgetType.upcomingTasks:
        return UpcomingTasksWidget(onViewAll: () => onTabChange?.call(1));
      case WidgetType.calendar:
        return CalendarWidget(onViewAll: () => onTabChange?.call(2));
      case WidgetType.notes:
        return RecentNotesWidget(onViewAll: () => onTabChange?.call(3));
      case WidgetType.reminders:
        return RemindersWidget(onViewAll: () {});
      case WidgetType.productivity:
        return ProductivityWidget();
      case WidgetType.quickActions:
        return QuickActionsWidget(onTabChange: onTabChange);
    }
  }
}

/// Base widget card with consistent styling
class _BaseWidgetCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final VoidCallback? onViewAll;
  final Color? accentColor;

  const _BaseWidgetCard({
    required this.title,
    required this.icon,
    required this.child,
    this.onViewAll,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = accentColor ?? theme.primaryColor;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(icon, color: color, size: 20.sp),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                if (onViewAll != null)
                  TextButton(
                    onPressed: onViewAll,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'View All',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          child,
        ],
      ),
    );
  }
}

/// Widget showing today's tasks
class TodayTasksWidget extends StatelessWidget {
  final VoidCallback? onViewAll;

  const TodayTasksWidget({super.key, this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TasksCubit, TasksState>(
      builder: (context, state) {
        final today = DateTime.now();
        final todayTasks = state.tasks.where((task) {
          return task.date.year == today.year &&
                 task.date.month == today.month &&
                 task.date.day == today.day &&
                 !task.isDone;
        }).take(5).toList();

        return _BaseWidgetCard(
          title: "Today's Tasks",
          icon: Icons.today_rounded,
          onViewAll: onViewAll,
          accentColor: Colors.blue,
          child: todayTasks.isEmpty
              ? _buildEmptyTasks('No tasks for today')
              : _buildTasksList(context, todayTasks),
        );
      },
    );
  }

  Widget _buildEmptyTasks(String message) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.grey.shade400, size: 24.sp),
            SizedBox(width: 12.w),
            Text(
              message,
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTasksList(BuildContext context, List<task_entities.TaskEntity> tasks) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
      child: Column(
        children: tasks.map((task) => _TaskItem(task: task)).toList(),
      ),
    );
  }
}

/// Widget showing upcoming tasks
class UpcomingTasksWidget extends StatelessWidget {
  final VoidCallback? onViewAll;

  const UpcomingTasksWidget({super.key, this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TasksCubit, TasksState>(
      builder: (context, state) {
        final now = DateTime.now();
        final tomorrow = now.add(const Duration(days: 1));
        final weekFromNow = now.add(const Duration(days: 7));

        final upcomingTasks = state.tasks.where((task) {
          return task.date.isAfter(now) &&
                 task.date.isBefore(weekFromNow) &&
                 !task.isDone;
        }).take(5).toList();

        return _BaseWidgetCard(
          title: 'Upcoming Tasks',
          icon: Icons.upcoming_rounded,
          onViewAll: onViewAll,
          accentColor: Colors.orange,
          child: upcomingTasks.isEmpty
              ? _buildEmptyState()
              : _buildUpcomingList(context, upcomingTasks),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Icon(Icons.event_available, color: Colors.grey.shade400, size: 24.sp),
            SizedBox(width: 12.w),
            Text(
              'No upcoming tasks this week',
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingList(BuildContext context, List<task_entities.TaskEntity> tasks) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
      child: Column(
        children: tasks.map((task) => _TaskItem(task: task, showDate: true)).toList(),
      ),
    );
  }
}

/// Single task item widget
class _TaskItem extends StatelessWidget {
  final task_entities.TaskEntity task;
  final bool showDate;

  const _TaskItem({required this.task, this.showDate = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 20.w,
            height: 20.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: _getPriorityColor(task.priority),
                width: 2,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (showDate)
                  Padding(
                    padding: EdgeInsets.only(top: 4.h),
                    child: Text(
                      DateFormat('EEE, MMM d').format(task.date),
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (task.totalSubtasks > 0)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                '${task.completedSubtasks}/${task.totalSubtasks}',
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  color: theme.primaryColor,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getPriorityColor(priority) {
    switch (priority.toString()) {
      case 'TaskPriority.high':
        return Colors.red;
      case 'TaskPriority.medium':
        return Colors.orange;
      case 'TaskPriority.low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

/// Calendar widget showing upcoming events
class CalendarWidget extends StatelessWidget {
  final VoidCallback? onViewAll;

  const CalendarWidget({super.key, this.onViewAll});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final theme = Theme.of(context);
    
    return _BaseWidgetCard(
      title: 'Calendar',
      icon: Icons.calendar_month_rounded,
      onViewAll: onViewAll,
      accentColor: Colors.purple,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
        child: Row(
          children: List.generate(7, (index) {
            final date = now.add(Duration(days: index));
            final isToday = index == 0;
            
            return Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 2.w),
                padding: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                  color: isToday ? theme.primaryColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Column(
                  children: [
                    Text(
                      DateFormat('E').format(date).substring(0, 1),
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: isToday ? Colors.white70 : Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      date.day.toString(),
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: isToday ? Colors.white : theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

/// Recent notes widget
class RecentNotesWidget extends StatelessWidget {
  final VoidCallback? onViewAll;

  const RecentNotesWidget({super.key, this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotesCubit, NotesState>(
      builder: (context, state) {
        final recentNotes = (state.notes.toList()
          ..sort((a, b) => b.lastEditDate.compareTo(a.lastEditDate)))
          .take(3).toList();

        return _BaseWidgetCard(
          title: 'Recent Notes',
          icon: Icons.note_alt_rounded,
          onViewAll: onViewAll,
          accentColor: Colors.teal,
          child: recentNotes.isEmpty
              ? _buildEmptyState()
              : _buildNotesList(context, recentNotes),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Icon(Icons.note_add_outlined, color: Colors.grey.shade400, size: 24.sp),
            SizedBox(width: 12.w),
            Text(
              'No notes yet',
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesList(BuildContext context, List<note_entities.NoteEntity> notes) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
      child: Column(
        children: notes.map((note) => _NoteItem(note: note)).toList(),
      ),
    );
  }
}

/// Single note item widget
class _NoteItem extends StatelessWidget {
  final note_entities.NoteEntity note;

  const _NoteItem({required this.note});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.teal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              Icons.description_outlined,
              color: Colors.teal,
              size: 16.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note.title,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  _formatTimeAgo(note.lastEditDate),
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

/// Reminders widget
class RemindersWidget extends StatelessWidget {
  final VoidCallback? onViewAll;

  const RemindersWidget({super.key, this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return _BaseWidgetCard(
      title: 'Reminders',
      icon: Icons.notifications_active_rounded,
      onViewAll: onViewAll,
      accentColor: Colors.amber,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            children: [
              Icon(Icons.notifications_none, color: Colors.grey.shade400, size: 24.sp),
              SizedBox(width: 12.w),
              Text(
                'No active reminders',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Productivity stats widget
class ProductivityWidget extends StatelessWidget {
  const ProductivityWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TasksCubit, TasksState>(
      builder: (context, state) {
        final totalTasks = state.tasks.length;
        final completedTasks = state.tasks.where((t) => t.isDone).length;
        final progress = totalTasks > 0 ? completedTasks / totalTasks : 0.0;

        return _BaseWidgetCard(
          title: 'Productivity',
          icon: Icons.insights_rounded,
          accentColor: Colors.indigo,
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
            child: Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Completed',
                    value: completedTasks.toString(),
                    icon: Icons.check_circle_rounded,
                    color: Colors.green,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _StatCard(
                    label: 'Pending',
                    value: (totalTasks - completedTasks).toString(),
                    icon: Icons.pending_rounded,
                    color: Colors.orange,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _StatCard(
                    label: 'Progress',
                    value: '${(progress * 100).toInt()}%',
                    icon: Icons.trending_up_rounded,
                    color: Colors.indigo,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20.sp),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Quick actions widget
class QuickActionsWidget extends StatelessWidget {
  final Function(int)? onTabChange;

  const QuickActionsWidget({super.key, this.onTabChange});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _BaseWidgetCard(
      title: 'Quick Actions',
      icon: Icons.flash_on_rounded,
      accentColor: Colors.deepPurple,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _QuickActionButton(
              icon: Icons.add_task_rounded,
              label: 'New Task',
              color: Colors.blue,
              onTap: () => onTabChange?.call(1),
            ),
            _QuickActionButton(
              icon: Icons.note_add_rounded,
              label: 'New Note',
              color: Colors.teal,
              onTap: () => onTabChange?.call(3),
            ),
            _QuickActionButton(
              icon: Icons.calendar_today_rounded,
              label: 'Calendar',
              color: Colors.purple,
              onTap: () => onTabChange?.call(2),
            ),
            _QuickActionButton(
              icon: Icons.mic_rounded,
              label: 'Voice',
              color: theme.primaryColor,
              onTap: () {
                // Voice action would be handled by the parent
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: color, size: 22.sp),
            ),
            SizedBox(height: 8.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
