import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:voclio_app/core/widgets/home_system/home_system_tokens.dart';
import 'package:voclio_app/features/calendar/presentation/bloc/calendar_cubit.dart';
import 'package:voclio_app/features/calendar/presentation/bloc/calendar_state.dart';
import 'package:voclio_app/features/dashboard/domain/entities/dashboard_stats_entity.dart'
    as dashboard;
import 'package:voclio_app/features/dashboard/presentation/bloc/dashboard_cubit.dart';
import 'package:voclio_app/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:voclio_app/features/tasks/presentation/bloc/tasks_cubit.dart';
import 'package:voclio_app/features/tasks/presentation/bloc/tasks_state.dart';
import 'package:voclio_app/features/tasks/domain/entities/task_entity.dart'
    as task_entities;
import 'package:voclio_app/features/calendar/domain/entities/calendar_month_entity.dart';
import '../../domain/entities/widget_preference.dart';
import '../bloc/widget_config_cubit.dart';
import '../bloc/widget_config_state.dart';

DayEventsEntity? _eventsForDate(DateTime date, CalendarMonthEntity? monthData) {
  if (monthData == null) return null;
  if (date.year != monthData.year || date.month != monthData.month) {
    return null;
  }
  return monthData.eventsByDay[date.day];
}

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
          return _buildEmptyState();
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
                    .slideY(
                      begin: 0.1,
                      delay: Duration(milliseconds: 100 * index),
                    ),
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: HomeSystemTokens.cardDecoration(),
      child: Column(
        children: [
          Icon(
            Icons.widgets_outlined,
            size: 40.sp,
            color: HomeSystemTokens.inkMuted,
          ),
          SizedBox(height: 12.h),
          Text(
            'No widgets enabled',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: HomeSystemTokens.inkSoft,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Go to settings to customize your home screen',
            style: TextStyle(fontSize: 13.sp, color: HomeSystemTokens.inkMuted),
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
        return RemindersWidget(onViewAll: () => onTabChange?.call(1));
      case WidgetType.productivity:
        return const ProductivityWidget();
      case WidgetType.quickActions:
        return QuickActionsWidget(onTabChange: onTabChange);
    }
  }
}

class _BaseWidgetCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final VoidCallback? onViewAll;
  final Color accent;

  const _BaseWidgetCard({
    required this.title,
    required this.icon,
    required this.child,
    this.onViewAll,
    this.accent = HomeSystemTokens.purple,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: HomeSystemTokens.cardDecoration(),
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
                    color: accent.withValues(alpha: 0.1),
                    borderRadius:
                        BorderRadius.circular(HomeSystemTokens.radiusSm.r),
                  ),
                  child: Icon(icon, color: accent, size: 18.sp),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: HomeSystemTokens.ink,
                    ),
                  ),
                ),
                if (onViewAll != null)
                  GestureDetector(
                    onTap: onViewAll,
                    child: Text(
                      'View all',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: accent,
                        fontWeight: FontWeight.w600,
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

/// Today's tasks from tasks API
class TodayTasksWidget extends StatelessWidget {
  final VoidCallback? onViewAll;

  const TodayTasksWidget({super.key, this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TasksCubit>.value(
      value: GetIt.I<TasksCubit>(),
      child: BlocBuilder<TasksCubit, TasksState>(
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
            accent: HomeSystemTokens.purple,
            child: todayTasks.isEmpty
                ? _emptyRow('No tasks for today')
                : _tasksList(todayTasks),
          );
        },
      ),
    );
  }

  Widget _tasksList(List<task_entities.TaskEntity> tasks) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
      child: Column(
        children: tasks.map((t) => _TaskItem(task: t)).toList(),
      ),
    );
  }
}

/// Upcoming tasks from dashboard API
class UpcomingTasksWidget extends StatelessWidget {
  final VoidCallback? onViewAll;

  const UpcomingTasksWidget({super.key, this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        final tasks = state is DashboardStatsLoaded
            ? state.stats.upcomingTasks
            : <dashboard.TaskEntity>[];

        return _BaseWidgetCard(
          title: 'Upcoming Tasks',
          icon: Icons.upcoming_rounded,
          onViewAll: onViewAll,
          accent: HomeSystemTokens.orange,
          child: state is DashboardLoading
              ? _loadingBody()
              : tasks.isEmpty
                  ? _emptyRow('No upcoming tasks this week')
                  : Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                      child: Column(
                        children: tasks
                            .map((t) => _DashboardTaskItem(task: t))
                            .toList(),
                      ),
                    ),
        );
      },
    );
  }
}

class RecentNotesWidget extends StatelessWidget {
  final VoidCallback? onViewAll;

  const RecentNotesWidget({super.key, this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        final notes = state is DashboardStatsLoaded
            ? state.stats.recentNotes
            : <dashboard.NoteEntity>[];

        return _BaseWidgetCard(
          title: 'Recent Notes',
          icon: Icons.note_alt_rounded,
          onViewAll: onViewAll,
          accent: HomeSystemTokens.blue,
          child: state is DashboardLoading
              ? _loadingBody()
              : notes.isEmpty
                  ? _emptyRow('No notes yet')
                  : Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                      child: Column(
                        children:
                            notes.map((n) => _NoteItem(note: n)).toList(),
                      ),
                    ),
        );
      },
    );
  }
}

class RemindersWidget extends StatelessWidget {
  final VoidCallback? onViewAll;

  const RemindersWidget({super.key, this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        final reminders = state is DashboardStatsLoaded
            ? state.stats.upcomingReminders
            : <dashboard.DashboardReminderEntity>[];

        return _BaseWidgetCard(
          title: 'Reminders',
          icon: Icons.notifications_active_rounded,
          onViewAll: onViewAll,
          accent: HomeSystemTokens.orange,
          child: state is DashboardLoading
              ? _loadingBody()
              : reminders.isEmpty
                  ? _emptyRow('No active reminders')
                  : Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                      child: Column(
                        children: reminders
                            .map((r) => _ReminderItem(reminder: r))
                            .toList(),
                      ),
                    ),
        );
      },
    );
  }
}

class ProductivityWidget extends StatelessWidget {
  const ProductivityWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        if (state is DashboardLoading) {
          return _BaseWidgetCard(
            title: 'Productivity',
            icon: Icons.insights_rounded,
            accent: HomeSystemTokens.green,
            child: _loadingBody(),
          );
        }

        final overview = state is DashboardStatsLoaded
            ? state.stats.overview
            : null;
        final productivity = state is DashboardStatsLoaded
            ? state.stats.productivity
            : null;

        return _BaseWidgetCard(
          title: 'Productivity',
          icon: Icons.insights_rounded,
          accent: HomeSystemTokens.green,
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
            child: Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Completed',
                    value: '${overview?.completedTasks ?? 0}',
                    icon: Icons.check_circle_rounded,
                    color: HomeSystemTokens.green,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: _StatCard(
                    label: 'Pending',
                    value: '${overview?.pendingTasks ?? 0}',
                    icon: Icons.pending_rounded,
                    color: HomeSystemTokens.orange,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: _StatCard(
                    label: 'Focus',
                    value: '${productivity?.todayFocusMinutes ?? 0}m',
                    icon: Icons.timer_outlined,
                    color: HomeSystemTokens.purple,
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

class QuickActionsWidget extends StatelessWidget {
  final Function(int)? onTabChange;

  const QuickActionsWidget({super.key, this.onTabChange});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        final actions = state is DashboardStatsLoaded
            ? state.stats.quickActions
            : <dashboard.QuickActionEntity>[];

        return _BaseWidgetCard(
          title: 'Quick Actions',
          icon: Icons.flash_on_rounded,
          accent: HomeSystemTokens.purple,
          child: Padding(
            padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 16.h),
            child: actions.isEmpty
                ? _emptyRow('No quick actions available')
                : Row(
                    children: actions.take(4).map((action) {
                      return Expanded(
                        child: _QuickActionButton(
                          icon: _iconFromApi(action.icon),
                          label: action.label,
                          color: HomeSystemTokens.purple,
                          onTap: () => _handleAction(action.id),
                        ),
                      );
                    }).toList(),
                  ),
          ),
        );
      },
    );
  }

  void _handleAction(String id) {
    switch (id) {
      case 'create_task':
        onTabChange?.call(1);
      case 'view_calendar':
        onTabChange?.call(2);
      case 'create_note':
        onTabChange?.call(3);
      case 'record_voice':
        break;
    }
  }
}

class CalendarWidget extends StatelessWidget {
  final VoidCallback? onViewAll;

  const CalendarWidget({super.key, this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CalendarCubit, CalendarState>(
      builder: (context, state) {
        final now = DateTime.now();
        final monthData =
            state is CalendarLoaded ? state.monthData : null;
        final todayEvents = _eventsForDate(now, monthData);

        return _BaseWidgetCard(
          title: 'Calendar',
          icon: Icons.calendar_month_rounded,
          onViewAll: onViewAll,
          accent: HomeSystemTokens.purple,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 12.h),
                child: Row(
                  children: List.generate(7, (index) {
                    final date = now.add(Duration(days: index));
                    final isToday = index == 0;
                    final hasEvents =
                        (_eventsForDate(date, monthData)?.totalCount ?? 0) > 0;

                    return Expanded(
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 2.w),
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                        decoration: BoxDecoration(
                          color: isToday
                              ? HomeSystemTokens.purple
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Column(
                          children: [
                            Text(
                              DateFormat('E').format(date).substring(0, 1),
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: isToday
                                    ? Colors.white70
                                    : HomeSystemTokens.inkMuted,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              '${date.day}',
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: isToday
                                    ? Colors.white
                                    : HomeSystemTokens.ink,
                              ),
                            ),
                            if (hasEvents)
                              Container(
                                margin: EdgeInsets.only(top: 4.h),
                                width: 4.w,
                                height: 4.w,
                                decoration: BoxDecoration(
                                  color: isToday
                                      ? Colors.white
                                      : HomeSystemTokens.purple,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
              if (state is CalendarLoading)
                _loadingBody()
              else if (todayEvents == null || todayEvents.totalCount == 0)
                _emptyRow('No events today')
              else
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                  child: Column(
                    children: [
                      ...todayEvents.tasks.take(2).map(
                            (t) => _CalendarEventRow(
                              title: t.title,
                              time: DateFormat('h:mm a').format(t.dueDate),
                            ),
                          ),
                      ...todayEvents.reminders.take(2).map(
                            (r) => _CalendarEventRow(
                              title: r.title,
                              time: DateFormat('h:mm a').format(r.reminderTime),
                            ),
                          ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// --- Shared item widgets ---

Widget _emptyRow(String message) {
  return Padding(
    padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
    child: Text(
      message,
      style: TextStyle(fontSize: 13.sp, color: HomeSystemTokens.inkMuted),
    ),
  );
}

Widget _loadingBody() {
  return Padding(
    padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 20.h),
    child: Center(
      child: SizedBox(
        width: 22.w,
        height: 22.w,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: HomeSystemTokens.purple,
        ),
      ),
    ),
  );
}

class _TaskItem extends StatelessWidget {
  final task_entities.TaskEntity task;

  const _TaskItem({required this.task});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: HomeSystemTokens.canvas,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Container(
            width: 8.w,
            height: 8.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _priorityColor(task.priority.toString()),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              task.title,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: HomeSystemTokens.ink,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardTaskItem extends StatelessWidget {
  final dashboard.TaskEntity task;

  const _DashboardTaskItem({required this.task});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: HomeSystemTokens.canvas,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: HomeSystemTokens.ink,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (task.dueDate != null)
                  Padding(
                    padding: EdgeInsets.only(top: 4.h),
                    child: Text(
                      DateFormat('EEE, MMM d • h:mm a').format(task.dueDate!),
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: HomeSystemTokens.inkMuted,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NoteItem extends StatelessWidget {
  final dashboard.NoteEntity note;

  const _NoteItem({required this.note});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: HomeSystemTokens.canvas,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(Icons.description_outlined,
              color: HomeSystemTokens.blue, size: 18.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note.title,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: HomeSystemTokens.ink,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _formatTimeAgo(note.createdAt),
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: HomeSystemTokens.inkMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReminderItem extends StatelessWidget {
  final dashboard.DashboardReminderEntity reminder;

  const _ReminderItem({required this.reminder});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: HomeSystemTokens.canvas,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(Icons.alarm_rounded,
              color: HomeSystemTokens.orange, size: 18.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminder.title,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: HomeSystemTokens.ink,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  DateFormat('MMM d • h:mm a').format(reminder.remindAt),
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: HomeSystemTokens.inkMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarEventRow extends StatelessWidget {
  final String title;
  final String time;

  const _CalendarEventRow({required this.title, required this.time});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Icon(Icons.event_rounded,
              size: 16.sp, color: HomeSystemTokens.purple),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              title,
              style: TextStyle(fontSize: 13.sp, color: HomeSystemTokens.ink),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            time,
            style: TextStyle(fontSize: 11.sp, color: HomeSystemTokens.inkMuted),
          ),
        ],
      ),
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
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 18.sp),
          SizedBox(height: 6.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 10.sp, color: HomeSystemTokens.inkMuted),
            textAlign: TextAlign.center,
          ),
        ],
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
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: color, size: 20.sp),
            ),
            SizedBox(height: 6.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w500,
                color: HomeSystemTokens.inkSoft,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

Color _priorityColor(String priority) {
  final p = priority.toLowerCase();
  if (p.contains('high')) return HomeSystemTokens.coral;
  if (p.contains('medium')) return HomeSystemTokens.orange;
  if (p.contains('low')) return HomeSystemTokens.green;
  return HomeSystemTokens.purple;
}

IconData _iconFromApi(String icon) {
  switch (icon) {
    case 'microphone':
      return Icons.mic_rounded;
    case 'check-circle':
      return Icons.add_task_rounded;
    case 'calendar':
      return Icons.calendar_today_rounded;
    case 'file-text':
      return Icons.note_add_rounded;
    default:
      return Icons.flash_on_rounded;
  }
}

String _formatTimeAgo(DateTime date) {
  final diff = DateTime.now().difference(date);
  if (diff.inDays > 0) return '${diff.inDays}d ago';
  if (diff.inHours > 0) return '${diff.inHours}h ago';
  if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
  return 'Just now';
}
