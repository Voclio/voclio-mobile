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
import 'package:voclio_app/core/icons/app_icons.dart';
import 'package:voclio_app/core/di/injection_container.dart';
import 'package:voclio_app/core/routes/App_routes.dart';
import 'package:voclio_app/features/reminders/domain/entities/reminder_entity.dart';
import 'package:voclio_app/features/reminders/presentation/cubit/reminders_cubit.dart';
import 'package:go_router/go_router.dart';

bool _isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

DateTime _dateOnly(DateTime date) =>
    DateTime(date.year, date.month, date.day);

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
            AppIcons.widgets_outlined,
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
        return RemindersWidget(
          onViewAll: () => context.push(AppRouter.reminders),
        );
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
            icon: AppIcons.today_rounded,
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
          icon: AppIcons.upcoming_rounded,
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
          icon: AppIcons.note_alt_rounded,
          onViewAll: onViewAll,
          accent: HomeSystemTokens.blue,
          child: state is DashboardLoading
              ? _loadingBody()
              : notes.isEmpty
                  ? _emptyRow('No notes yet')
                  : _WidgetHorizontalSlider(
                      height: 118,
                      children: notes.map((n) => _NoteItem(note: n)).toList(),
                    ),
        );
      },
    );
  }
}

List<ReminderEntity> _visibleHomeReminders(List<ReminderEntity> reminders) {
  final now = DateTime.now();
  final today = _dateOnly(now);

  return reminders
      .where((r) => r.isActive)
      .where(
        (r) =>
            r.remindAt.isAfter(now) ||
            _isSameDay(_dateOnly(r.remindAt), today),
      )
      .toList()
    ..sort((a, b) => a.remindAt.compareTo(b.remindAt));
}

class RemindersWidget extends StatelessWidget {
  final VoidCallback? onViewAll;

  const RemindersWidget({super.key, this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<RemindersCubit>()..loadReminders(),
      child: BlocBuilder<RemindersCubit, RemindersState>(
        builder: (context, state) {
          final reminders = state is RemindersLoaded
              ? _visibleHomeReminders(state.reminders).take(5).toList()
              : <ReminderEntity>[];

          return _BaseWidgetCard(
            title: 'Reminders',
            icon: AppIcons.notifications_active_rounded,
            onViewAll:
                onViewAll ?? () => context.push(AppRouter.reminders),
            accent: HomeSystemTokens.orange,
            child: state is RemindersLoading
                ? _loadingBody()
                : state is RemindersError
                    ? _emptyRow('Could not load reminders')
                    : reminders.isEmpty
                        ? _emptyRow('No active reminders')
                        : Padding(
                            padding:
                                EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                            child: Column(
                              children: reminders
                                  .map(
                                    (r) => _ReminderItem(
                                      title: r.title,
                                      remindAt: r.remindAt,
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
          );
        },
      ),
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
            icon: AppIcons.insights_rounded,
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
          icon: AppIcons.insights_rounded,
          accent: HomeSystemTokens.green,
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
            child: Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Completed',
                    value: '${overview?.completedTasks ?? 0}',
                    icon: AppIcons.check_circle_rounded,
                    color: HomeSystemTokens.green,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: _StatCard(
                    label: 'Pending',
                    value: '${overview?.pendingTasks ?? 0}',
                    icon: AppIcons.pending_rounded,
                    color: HomeSystemTokens.orange,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: _StatCard(
                    label: 'Focus',
                    value: '${productivity?.todayFocusMinutes ?? 0}m',
                    icon: AppIcons.timer_outlined,
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

        final visibleActions = actions
            .where((action) => action.id != 'record_voice')
            .take(3)
            .toList();
        final displayActions = visibleActions.isNotEmpty
            ? visibleActions
            : actions.take(3).toList();

        return _BaseWidgetCard(
          title: 'Quick Actions',
          icon: AppIcons.flash_on_rounded,
          accent: HomeSystemTokens.purple,
          child: Padding(
            padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 16.h),
            child: displayActions.isEmpty
                ? _emptyRow('No quick actions available')
                : Row(
                    children: [
                      for (var i = 0; i < displayActions.length; i++) ...[
                        if (i > 0) SizedBox(width: 10.w),
                        Expanded(
                          child: _QuickActionButton(
                            icon: _iconFromApi(displayActions[i].icon),
                            label: _quickActionLabel(displayActions[i]),
                            color: HomeSystemTokens.purple,
                            onTap: () => _handleAction(displayActions[i].id),
                          ),
                        ),
                      ],
                    ],
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

  String _quickActionLabel(dashboard.QuickActionEntity action) {
    switch (action.id) {
      case 'create_task':
        return 'New Task';
      case 'view_calendar':
        return 'Calendar';
      case 'create_note':
        return 'New Note';
      case 'record_voice':
        return 'Voice';
      default:
        return action.label;
    }
  }
}

class CalendarWidget extends StatefulWidget {
  final VoidCallback? onViewAll;

  const CalendarWidget({super.key, this.onViewAll});

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = _dateOnly(DateTime.now());
  }

  void _selectDate(BuildContext context, DateTime date, int year, int month) {
    final normalized = _dateOnly(date);
    setState(() => _selectedDate = normalized);

    final cubit = context.read<CalendarCubit>();
    final state = cubit.state;
    if (state is CalendarLoaded) {
      final loaded = state.monthData;
      if (loaded.year != year || loaded.month != month) {
        cubit.loadMonth(year, month);
      }
    } else {
      cubit.loadMonth(year, month);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TasksCubit>.value(
      value: GetIt.I<TasksCubit>(),
      child: BlocBuilder<CalendarCubit, CalendarState>(
        builder: (context, state) {
          final today = _dateOnly(DateTime.now());
          final monthData =
              state is CalendarLoaded ? state.monthData : null;
          final selectedEvents = _eventsForDate(_selectedDate, monthData);
          final allTasks = GetIt.I<TasksCubit>().state.allTasks;

          return _BaseWidgetCard(
            title: 'Calendar',
            icon: AppIcons.calendar_month_rounded,
            onViewAll: widget.onViewAll,
            accent: HomeSystemTokens.purple,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 8.h),
                  child: Row(
                    children: List.generate(7, (index) {
                      final date = today.add(Duration(days: index));
                      final isSelected = _isSameDay(date, _selectedDate);
                      final isToday = _isSameDay(date, today);
                      final hasEvents =
                          (_eventsForDate(date, monthData)?.totalCount ?? 0) >
                              0;

                      return Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => _selectDate(
                            context,
                            date,
                            date.year,
                            date.month,
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 2.w),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  curve: Curves.easeOut,
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(vertical: 5.h),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? HomeSystemTokens.purple
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        DateFormat('E')
                                            .format(date)
                                            .substring(0, 1),
                                        style: TextStyle(
                                          fontSize: 9.sp,
                                          fontWeight: FontWeight.w600,
                                          color: isSelected
                                              ? Colors.white70
                                              : HomeSystemTokens.inkMuted,
                                        ),
                                      ),
                                      SizedBox(height: 2.h),
                                      Text(
                                        '${date.day}',
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w700,
                                          color: isSelected
                                              ? Colors.white
                                              : HomeSystemTokens.ink,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 3.h),
                                SizedBox(
                                  height: 5.h,
                                  child: hasEvents
                                      ? Container(
                                          width: 4.w,
                                          height: 4.w,
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? HomeSystemTokens.purple
                                                : isToday
                                                    ? HomeSystemTokens.purple
                                                        .withValues(alpha: 0.5)
                                                    : HomeSystemTokens.purple,
                                            shape: BoxShape.circle,
                                          ),
                                        )
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                if (state is CalendarLoading)
                  _loadingBody()
                else if (selectedEvents == null ||
                    selectedEvents.totalCount == 0)
                  _emptyRow(
                    _isSameDay(_selectedDate, today)
                        ? 'No events today'
                        : 'No events on this day',
                  )
                else
                  _WidgetHorizontalSlider(
                    height: 140,
                    children: [
                      ...selectedEvents.tasks.take(5).map(
                            (task) => _CalendarTaskCard(
                              task,
                              description: _taskDescription(allTasks, task),
                            ),
                          ),
                      ...selectedEvents.reminders.take(3).map(
                            _CalendarReminderCard.new,
                          ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

String? _taskDescription(
  List<task_entities.TaskEntity> tasks,
  CalendarTaskEntity calendarTask,
) {
  for (final task in tasks) {
    if (task.id == calendarTask.id.toString()) {
      final description = task.description?.trim();
      if (description != null && description.isNotEmpty) {
        return description;
      }
      return null;
    }
  }
  final fromCalendar = calendarTask.description?.trim();
  if (fromCalendar != null && fromCalendar.isNotEmpty) {
    return fromCalendar;
  }
  return null;
}

// --- Shared item widgets ---

class _WidgetHorizontalSlider extends StatelessWidget {
  final List<Widget> children;
  final double height;

  const _WidgetHorizontalSlider({
    required this.children,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) {
      return const SizedBox.shrink();
    }

    final itemWidth = MediaQuery.sizeOf(context).width * 0.74;

    return SizedBox(
      height: height.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
        physics: const BouncingScrollPhysics(),
        itemCount: children.length,
        separatorBuilder: (_, __) => SizedBox(width: 10.w),
        itemBuilder: (_, index) => SizedBox(
          width: itemWidth,
          child: children[index],
        ),
      ),
    );
  }
}

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
    final description = task.description?.trim();

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: HomeSystemTokens.canvas,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 2.h),
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: _priorityColor(task.priority.toString())
                  .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              AppIcons.task_alt_rounded,
              size: 16.sp,
              color: _priorityColor(task.priority.toString()),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: HomeSystemTokens.ink,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (description != null && description.isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: HomeSystemTokens.inkSoft,
                      height: 1.35,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                SizedBox(height: 6.h),
                Wrap(
                  spacing: 6.w,
                  runSpacing: 4.h,
                  children: [
                    _MetaChip(
                      label: _formatPriority(task.priority.toString()),
                      color: _priorityColor(task.priority.toString()),
                    ),
                    _MetaChip(
                      label: DateFormat('h:mm a').format(task.date),
                      color: HomeSystemTokens.inkMuted,
                    ),
                    if (task.totalSubtasks > 0)
                      _MetaChip(
                        label:
                            '${task.completedSubtasks}/${task.totalSubtasks} subtasks',
                        color: HomeSystemTokens.blue,
                      ),
                  ],
                ),
              ],
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 2.h),
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: _priorityColor(task.priority).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              AppIcons.task_alt_rounded,
              size: 16.sp,
              color: _priorityColor(task.priority),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: HomeSystemTokens.ink,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 6.h),
                Wrap(
                  spacing: 6.w,
                  runSpacing: 4.h,
                  children: [
                    _MetaChip(
                      label: _formatPriority(task.priority),
                      color: _priorityColor(task.priority),
                    ),
                    _MetaChip(
                      label: _formatStatus(task.status),
                      color: HomeSystemTokens.inkSoft,
                    ),
                    if (task.dueDate != null)
                      _MetaChip(
                        label: DateFormat('EEE, MMM d • h:mm a')
                            .format(task.dueDate!),
                        color: HomeSystemTokens.inkMuted,
                      ),
                  ],
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
    final preview = _cleanPreview(note.preview);

    return Container(
      height: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: HomeSystemTokens.canvas,
        borderRadius: BorderRadius.circular(12.r),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: HomeSystemTokens.blue.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              AppIcons.description_outlined,
              color: HomeSystemTokens.blue,
              size: 16.sp,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note.title.isNotEmpty ? note.title : 'Untitled note',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: HomeSystemTokens.ink,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (preview.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Text(
                    preview,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: HomeSystemTokens.inkSoft,
                      height: 1.25,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                SizedBox(height: 4.h),
                _MetaChip(
                  label: _formatTimeAgo(note.createdAt),
                  color: HomeSystemTokens.inkMuted,
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
  final String title;
  final DateTime remindAt;

  const _ReminderItem({required this.title, required this.remindAt});

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
          Icon(AppIcons.alarm_rounded,
              color: HomeSystemTokens.orange, size: 18.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: HomeSystemTokens.ink,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  DateFormat('MMM d • h:mm a').format(remindAt),
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

class _CalendarTaskCard extends StatelessWidget {
  final CalendarTaskEntity task;
  final String? description;

  const _CalendarTaskCard(this.task, {this.description});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: HomeSystemTokens.canvas,
        borderRadius: BorderRadius.circular(12.r),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: _priorityColor(task.priority).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              AppIcons.task_alt_rounded,
              size: 16.sp,
              color: _priorityColor(task.priority),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Task',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        color: HomeSystemTokens.purple,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      DateFormat('h:mm a').format(task.dueDate),
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: HomeSystemTokens.inkMuted,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Text(
                  task.title.isNotEmpty ? task.title : 'Untitled task',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: HomeSystemTokens.ink,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (description != null && description!.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Text(
                    description!,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: HomeSystemTokens.inkSoft,
                      height: 1.25,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Flexible(
                      child: _MetaChip(
                        label: _formatPriority(task.priority),
                        color: _priorityColor(task.priority),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Flexible(
                      child: _MetaChip(
                        label: _formatStatus(task.status),
                        color: HomeSystemTokens.inkSoft,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarReminderCard extends StatelessWidget {
  final CalendarReminderEntity reminder;

  const _CalendarReminderCard(this.reminder);

  @override
  Widget build(BuildContext context) {
    final title = reminder.title.trim().isEmpty ||
            reminder.title.toLowerCase() == 'task'
        ? 'Scheduled reminder'
        : reminder.title;

    return Container(
      height: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: HomeSystemTokens.canvas,
        borderRadius: BorderRadius.circular(12.r),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: HomeSystemTokens.orange.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              AppIcons.alarm_rounded,
              size: 16.sp,
              color: HomeSystemTokens.orange,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Reminder',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        color: HomeSystemTokens.orange,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      DateFormat('h:mm a').format(reminder.reminderTime),
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: HomeSystemTokens.inkMuted,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: HomeSystemTokens.ink,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final String label;
  final Color color;

  const _MetaChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
          color: color,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 10.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(icon, color: color, size: 22.sp),
              ),
              SizedBox(height: 8.h),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: HomeSystemTokens.inkSoft,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
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
      return AppIcons.mic_rounded;
    case 'check-circle':
      return AppIcons.add_task_rounded;
    case 'calendar':
      return AppIcons.calendar_today_rounded;
    case 'file-text':
      return AppIcons.note_add_rounded;
    default:
      return AppIcons.flash_on_rounded;
  }
}

String _formatTimeAgo(DateTime date) {
  final diff = DateTime.now().difference(date);
  if (diff.inDays > 0) return '${diff.inDays}d ago';
  if (diff.inHours > 0) return '${diff.inHours}h ago';
  if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
  return 'Just now';
}

String _formatPriority(String priority) {
  final value = priority.toLowerCase();
  if (value.contains('high')) return 'High priority';
  if (value.contains('medium')) return 'Medium priority';
  if (value.contains('low')) return 'Low priority';
  return 'No priority';
}

String _formatStatus(String status) {
  final value = status.toLowerCase().replaceAll('_', ' ');
  if (value.contains('complete') || value.contains('done')) {
    return 'Completed';
  }
  if (value.contains('progress')) return 'In progress';
  if (value.contains('todo') || value.contains('pending')) return 'To do';
  if (value.isEmpty) return 'Pending';
  return value[0].toUpperCase() + value.substring(1);
}

String _cleanPreview(String raw) {
  final collapsed = raw.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (collapsed.endsWith('...')) return collapsed;
  if (collapsed.length > 120) {
    return '${collapsed.substring(0, 117)}...';
  }
  return collapsed;
}
