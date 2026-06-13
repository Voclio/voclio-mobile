import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:get_it/get_it.dart';
import 'package:url_launcher/url_launcher.dart';
import '../bloc/calendar_cubit.dart';
import '../bloc/calendar_state.dart';
import '../../../tasks/presentation/widgets/add_task_buttom_sheet.dart';
import '../../../tasks/presentation/screens/task_details_screen.dart';
import '../../../tasks/presentation/bloc/tasks_cubit.dart';
import '../../../tasks/domain/entities/task_entity.dart';
import '../../../../core/enums/enums.dart';
import '../../domain/entities/calendar_month_entity.dart';
import '../../domain/entities/google_calendar_entity.dart';
import '../../../../core/common/dialogs/voclio_dialog.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../../../core/widgets/home_system/home_system_tokens.dart';
import '../../../../core/widgets/home_system/home_system_widgets.dart';
import 'package:voclio_app/core/icons/app_icons.dart';

class MonthlyCalendarScreen extends StatelessWidget {
  const MonthlyCalendarScreen({super.key});

  static final ValueNotifier<DateTime?> pendingJumpDate =
      ValueNotifier<DateTime?>(null);

  static void jumpTo(DateTime date) {
    pendingJumpDate.value = DateTime(date.year, date.month, date.day);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: GetIt.I<TasksCubit>(),
      child: const _MonthlyCalendarView(),
    );
  }
}

class _MonthlyCalendarView extends StatefulWidget {
  const _MonthlyCalendarView();

  @override
  State<_MonthlyCalendarView> createState() => _MonthlyCalendarViewState();
}

class _MonthlyCalendarViewState extends State<_MonthlyCalendarView> {
  static final Set<String> _processedOAuthCodes = {};

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String _selectedFilter = 'all'; // all, pending, completed, overdue
  bool _showGoogleEvents = true; // Toggle for showing Google Calendar events

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    MonthlyCalendarScreen.pendingJumpDate.addListener(_handlePendingJump);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _applyPendingJump();
      _completeOAuthIfNeeded();
      final cubit = context.read<CalendarCubit>();
      if (cubit.state is! CalendarLoaded) {
        final now = DateTime.now();
        cubit.loadMonth(now.year, now.month);
      }
    });
  }

  @override
  void dispose() {
    MonthlyCalendarScreen.pendingJumpDate.removeListener(_handlePendingJump);
    super.dispose();
  }

  void _handlePendingJump() {
    _applyPendingJump();
  }

  void _applyPendingJump() {
    final target = MonthlyCalendarScreen.pendingJumpDate.value;
    if (target == null || !mounted) return;

    setState(() {
      _focusedDay = target;
      _selectedDay = target;
    });
    context.read<CalendarCubit>().loadMonth(
      target.year,
      target.month,
      force: true,
    );
    MonthlyCalendarScreen.pendingJumpDate.value = null;
  }

  Future<void> _completeOAuthIfNeeded() async {
    final oauthCode =
        GoRouterState.of(context).uri.queryParameters['oauth_code'];
    if (oauthCode == null || oauthCode.isEmpty || !mounted) return;
    if (_processedOAuthCodes.contains(oauthCode)) return;
    _processedOAuthCodes.add(oauthCode);

    final cubit = context.read<CalendarCubit>();
    try {
      await cubit.handleOAuthCallback(oauthCode);
      if (!mounted) return;

      if (cubit.state is GoogleCalendarConnected ||
          cubit.state is CalendarLoaded) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Google Calendar connected successfully'),
          ),
        );
      } else if (cubit.state is CalendarError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text((cubit.state as CalendarError).message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to connect Google Calendar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        context.go('/calendar');
      }
    }
  }

  void _showAddTaskSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => BlocProvider.value(
            value: context.read<TasksCubit>(),
            child: const AddTaskBottomSheet(),
          ),
    ).then((_) {
      // Refresh calendar after adding task
      context.read<CalendarCubit>().loadMonth(
        _focusedDay.year,
        _focusedDay.month,
      );
    });
  }

  void _navigateToTaskDetails(
    BuildContext context,
    CalendarTaskEntity calendarTask,
  ) {
    // Convert CalendarTaskEntity to TaskEntity for the details screen
    final task = TaskEntity(
      id: calendarTask.id.toString(),
      title: calendarTask.title,
      date: calendarTask.dueDate,
      createdAt: calendarTask.dueDate,
      isDone: calendarTask.isCompleted,
      priority: _getPriorityEnum(calendarTask.priority),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => BlocProvider.value(
              value: context.read<TasksCubit>(),
              child: TaskDetailScreen(task: task),
            ),
      ),
    ).then((_) {
      // Refresh calendar after returning from task details
      context.read<CalendarCubit>().loadMonth(
        _focusedDay.year,
        _focusedDay.month,
      );
    });
  }

  TaskPriority _getPriorityEnum(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return TaskPriority.high;
      case 'medium':
        return TaskPriority.medium;
      case 'low':
        return TaskPriority.low;
      default:
        return TaskPriority.none;
    }
  }

  Future<void> _connectGoogleCalendar(BuildContext context) async {
    final cubit = context.read<CalendarCubit>();
    try {
      final urlEntity = await cubit.getGoogleConnectUrl();

      if (urlEntity.authUrl.isNotEmpty) {
        final uri = Uri.parse(urlEntity.authUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open Google sign-in')),
          );
        }
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not start Google Calendar connection'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google Calendar connect failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _disconnectGoogleCalendar(BuildContext context) async {
    final confirmed = await VoclioDialog.showConfirm(
      context: context,
      title: 'Disconnect Google Calendar?',
      message:
          'This will remove the Google Calendar sync. Your Google events will no longer appear in the calendar.',
      confirmText: 'Disconnect',
      cancelText: 'Cancel',
    );

    if (confirmed == true && context.mounted) {
      await context.read<CalendarCubit>().disconnectGoogleCalendar();
    }
  }

  void _showGoogleCalendarMenu(
    BuildContext context,
    ThemeData theme,
    bool isDark,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder:
          (ctx) => Padding(
            padding: EdgeInsets.all(20.r),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.r),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        AppIcons.event_available,
                        color: Colors.green,
                        size: 24.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Google Calendar Connected',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Your events are syncing',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                // Toggle show Google events
                ListTile(
                  leading: Icon(
                    _showGoogleEvents ? AppIcons.visibility : AppIcons.visibility_off,
                    color: theme.colorScheme.primary,
                  ),
                  title: Text(
                    _showGoogleEvents
                        ? 'Hide Google Events'
                        : 'Show Google Events',
                  ),
                  onTap: () {
                    setState(() {
                      _showGoogleEvents = !_showGoogleEvents;
                    });
                    Navigator.pop(ctx);
                  },
                ),
                // Refresh events
                ListTile(
                  leading: Icon(
                    AppIcons.refresh,
                    color: theme.colorScheme.primary,
                  ),
                  title: const Text('Refresh Events'),
                  onTap: () {
                    context.read<CalendarCubit>().loadMonth(
                      _focusedDay.year,
                      _focusedDay.month,
                    );
                    Navigator.pop(ctx);
                  },
                ),
                // Disconnect
                ListTile(
                  leading: Icon(AppIcons.link_off, color: Colors.red),
                  title: const Text(
                    'Disconnect Google Calendar',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _disconnectGoogleCalendar(context);
                  },
                ),
                SizedBox(height: 10.h),
              ],
            ),
          ),
    );
  }

  Widget _buildCalendarDayCell(
    DateTime day,
    CalendarMonthEntity monthData,
    ThemeData theme, {
    required BoxDecoration? decoration,
    required TextStyle textStyle,
    required bool isSelected,
  }) {
    if (day.month != monthData.month) return const SizedBox.shrink();

    final hasEvents =
        monthData.eventsByDay[day.day]?.tasks.isNotEmpty ?? false;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: 32.w,
          height: 32.w,
          decoration: decoration ?? const BoxDecoration(shape: BoxShape.circle),
          alignment: Alignment.center,
          child: Text('${day.day}', style: textStyle),
        ),
        SizedBox(height: 2.h),
        Container(
          width: 5.r,
          height: 5.r,
          decoration: BoxDecoration(
            color:
                hasEvents
                    ? (isSelected
                        ? Colors.white
                        : theme.colorScheme.primary)
                    : Colors.transparent,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }

  List<CalendarTaskEntity> _getFilteredTasks(List<CalendarTaskEntity> tasks) {
    final now = DateTime.now();
    switch (_selectedFilter) {
      case 'pending':
        return tasks
            .where(
              (t) =>
                  !t.isCompleted &&
                  !DateTimeUtils.isOverdue(
                    t.dueDate,
                    isCompleted: false,
                  ),
            )
            .toList();
      case 'completed':
        return tasks.where((t) => t.isCompleted).toList();
      case 'overdue':
        return tasks
            .where(
              (t) => DateTimeUtils.isOverdue(
                t.dueDate,
                isCompleted: t.isCompleted,
              ),
            )
            .toList();
      default:
        return tasks;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      primary: false,
      backgroundColor: HomeSystemTokens.canvas,
      appBar: AppBar(
        title: Text(
          'Calendar',
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.w800,
            color: HomeSystemTokens.ink,
            letterSpacing: -0.3,
          ),
        ),
        backgroundColor: HomeSystemTokens.canvas,
        elevation: 0,
        centerTitle: false,
        actions: [
          // Google Calendar toggle
          BlocBuilder<CalendarCubit, CalendarState>(
            buildWhen:
                (prev, curr) =>
                    curr is GoogleCalendarConnected ||
                    curr is GoogleCalendarDisconnected ||
                    curr is CalendarLoaded,
            builder: (context, state) {
              bool isConnected = false;
              if (state is CalendarLoaded) {
                isConnected = state.googleStatus?.isConnected ?? false;
              } else if (state is GoogleCalendarConnected) {
                isConnected = true;
              }

              return Container(
                margin: EdgeInsets.only(right: 4.w),
                decoration: BoxDecoration(
                  color:
                      isConnected
                          ? Colors.green.withOpacity(0.15)
                          : isDark
                          ? Colors.white10
                          : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: IconButton(
                  icon: Icon(
                    isConnected ? AppIcons.event_available : AppIcons.event_busy,
                    color:
                        isConnected
                            ? Colors.green
                            : theme.colorScheme.secondary,
                    size: 18.sp,
                  ),
                  onPressed: () {
                    if (isConnected) {
                      _showGoogleCalendarMenu(context, theme, isDark);
                    } else {
                      _connectGoogleCalendar(context);
                    }
                  },
                  tooltip: isConnected ? 'Google Calendar' : 'Connect Google',
                ),
              );
            },
          ),
          // Calendar view toggle
          Container(
            margin: EdgeInsets.only(right: 4.w),
            decoration: BoxDecoration(
              color: isDark ? Colors.white10 : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: IconButton(
              icon: Icon(
                _calendarFormat == CalendarFormat.month
                    ? AppIcons.calendar_view_week
                    : _calendarFormat == CalendarFormat.twoWeeks
                    ? AppIcons.calendar_view_day
                    : AppIcons.calendar_month,
                color: theme.colorScheme.onSurface,
                size: 18.sp,
              ),
              onPressed: () {
                setState(() {
                  if (_calendarFormat == CalendarFormat.month) {
                    _calendarFormat = CalendarFormat.twoWeeks;
                  } else if (_calendarFormat == CalendarFormat.twoWeeks) {
                    _calendarFormat = CalendarFormat.week;
                  } else {
                    _calendarFormat = CalendarFormat.month;
                  }
                });
              },
              tooltip: 'Change view',
            ),
          ),
          // Go to today button
          Container(
            margin: EdgeInsets.only(right: 16.w),
            decoration: BoxDecoration(
              color: isDark ? Colors.white10 : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: IconButton(
              icon: Icon(
                AppIcons.today,
                color: theme.colorScheme.onSurface,
                size: 20.sp,
              ),
              onPressed: () {
                setState(() {
                  _focusedDay = DateTime.now();
                  _selectedDay = DateTime.now();
                });
                context.read<CalendarCubit>().loadMonth(
                  DateTime.now().year,
                  DateTime.now().month,
                );
              },
              tooltip: 'Go to today',
            ),
          ),
        ],
      ),
      body: BlocConsumer<CalendarCubit, CalendarState>(
        listener: (context, state) {
          if (state is CalendarLoaded) {
            final monthData = state.monthData;
            final today = DateTime.now();

            // Only try to auto-select if we are in the currently focused month
            if (monthData.year == _focusedDay.year &&
                monthData.month == _focusedDay.month) {
              // If today has events, keep today selected
              if (monthData.eventsByDay.containsKey(today.day)) {
                setState(() {
                  _selectedDay = DateTime(today.year, today.month, today.day);
                });
              } else {
                // Find the nearest upcoming day with events
                final eventDays = monthData.eventsByDay.keys.toList()..sort();
                final upcomingDay = eventDays.firstWhere(
                  (day) => day >= today.day,
                  orElse:
                      () => eventDays.isNotEmpty ? eventDays.first : today.day,
                );

                setState(() {
                  _selectedDay = DateTime(
                    monthData.year,
                    monthData.month,
                    upcomingDay,
                  );
                  // Also update focused day to the selected day if it's far away?
                  // No, TableCalendar handles focusedDay for the month view.
                });
              }
            }
          }
        },
        builder: (context, state) {
          if (state is CalendarLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CalendarError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(AppIcons.error_outline, size: 48.sp, color: Colors.red),
                  SizedBox(height: 16.h),
                  Text(state.message, textAlign: TextAlign.center),
                  TextButton(
                    onPressed:
                        () => context.read<CalendarCubit>().loadMonth(
                          _focusedDay.year,
                          _focusedDay.month,
                        ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is CalendarLoaded) {
            final monthData = state.monthData;

            // Ensure _selectedDay is within the loaded month if we just switched pages
            final currentSelection = _selectedDay ?? _focusedDay;
            final effectiveSelection =
                (currentSelection.year == monthData.year &&
                        currentSelection.month == monthData.month)
                    ? currentSelection
                    : DateTime(monthData.year, monthData.month, 1);

            final selectedDayEvents =
                monthData.eventsByDay[effectiveSelection.day];

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // Month/Year Display
                  Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 10.h,
                        ),
                        child: Row(
                          children: [
                            Text(
                              DateFormat('MMMM yyyy').format(_focusedDay),
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14.sp,
                              ),
                            ),
                          ],
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .slideX(begin: -0.1, end: 0),

                  // Calendar Container
                  Container(
                        margin: EdgeInsets.symmetric(horizontal: 16.w),
                        padding: EdgeInsets.all(12.r),
                        decoration: BoxDecoration(
                          color:
                              isDark
                                  ? Colors.white.withOpacity(0.05)
                                  : Colors.white,
                          borderRadius: BorderRadius.circular(24.r),
                          boxShadow:
                              isDark
                                  ? []
                                  : [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 20,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                        ),
                        child: TableCalendar(
                          firstDay: DateTime.utc(2020, 1, 1),
                          lastDay: DateTime.utc(2030, 12, 31),
                          focusedDay: _focusedDay,
                          rowHeight: 52.h,
                          calendarFormat: _calendarFormat,
                          selectedDayPredicate:
                              (day) => isSameDay(effectiveSelection, day),
                          eventLoader: (day) {
                            if (day.month != monthData.month) return [];
                            return monthData.eventsByDay[day.day]?.tasks ?? [];
                          },
                          onDaySelected: (selectedDay, focusedDay) {
                            setState(() {
                              _selectedDay = selectedDay;
                              _focusedDay = focusedDay;
                            });
                          },
                          onFormatChanged: (format) {
                            setState(() {
                              _calendarFormat = format;
                            });
                          },
                          onPageChanged: (focusedDay) {
                            setState(() {
                              _focusedDay = focusedDay;
                              _selectedDay =
                                  null; // Reset selection so listener can pick the best day for the new month
                            });
                            context.read<CalendarCubit>().loadMonth(
                              focusedDay.year,
                              focusedDay.month,
                            );
                          },
                          calendarStyle: CalendarStyle(
                            cellMargin: EdgeInsets.zero,
                            outsideDaysVisible: false,
                            defaultTextStyle: TextStyle(
                              color: theme.colorScheme.onSurface,
                              fontSize: 14.sp,
                            ),
                            weekendTextStyle: TextStyle(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.7,
                              ),
                              fontSize: 14.sp,
                            ),
                          ),
                          calendarBuilders: CalendarBuilders(
                            markerBuilder: (context, day, events) =>
                                const SizedBox.shrink(),
                            defaultBuilder: (context, day, focusedDay) =>
                                _buildCalendarDayCell(
                                  day,
                                  monthData,
                                  theme,
                                  decoration: null,
                                  textStyle: TextStyle(
                                    color:
                                        day.weekday == DateTime.saturday ||
                                                day.weekday == DateTime.sunday
                                            ? theme.colorScheme.primary
                                                .withValues(alpha: 0.7)
                                            : theme.colorScheme.onSurface,
                                    fontSize: 14.sp,
                                  ),
                                  isSelected: false,
                                ),
                            todayBuilder: (context, day, focusedDay) =>
                                _buildCalendarDayCell(
                                  day,
                                  monthData,
                                  theme,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary.withValues(
                                      alpha: 0.15,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  textStyle: TextStyle(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14.sp,
                                  ),
                                  isSelected: false,
                                ),
                            selectedBuilder: (context, day, focusedDay) =>
                                _buildCalendarDayCell(
                                  day,
                                  monthData,
                                  theme,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  textStyle: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  isSelected: true,
                                ),
                          ),
                          headerStyle: const HeaderStyle(
                            formatButtonVisible: false,
                            titleCentered: true,
                            titleTextStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .scale(begin: const Offset(0.98, 0.98)),

                  SizedBox(height: 20.h),

                  if (state.googleStatus == null ||
                      !state.googleStatus!.isConnected)
                    _buildGoogleCalendarBanner(context, theme, isDark),

                  // Today's meetings section (if connected and it's today)
                  if (isSameDay(effectiveSelection, DateTime.now()) &&
                      state.todayMeetings != null &&
                      state.todayMeetings!.isNotEmpty)
                    _buildTodayMeetingsSection(
                      state.todayMeetings!,
                      theme,
                      isDark,
                    ),

                  // Selected day tasks header + filter chips
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: _buildDayTasksHeader(
                      effectiveSelection,
                      selectedDayEvents?.tasks ?? [],
                    ),
                  ).animate().fadeIn(duration: 400.ms, delay: 200.ms),

                  SizedBox(height: 12.h),

                  // Events List
                  _buildEventsList(selectedDayEvents, theme, isDark, context),

                  SizedBox(height: 100.h), // Space for bottom nav
                ],
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildDayTasksHeader(
    DateTime selectedDay,
    List<CalendarTaskEntity> tasks,
  ) {
    final isToday = isSameDay(selectedDay, DateTime.now());
    final title =
        isToday
            ? 'Today\'s Tasks'
            : 'Tasks for ${DateFormat('MMM d').format(selectedDay)}';
    final filtered = _getFilteredTasks(tasks);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w700,
                  color: HomeSystemTokens.ink,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            if (tasks.isNotEmpty)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: HomeSystemTokens.purple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(100.r),
                ),
                child: Text(
                  '${filtered.length}/${tasks.length}',
                  style: TextStyle(
                    color: HomeSystemTokens.purple,
                    fontWeight: FontWeight.w700,
                    fontSize: 12.sp,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: 10.h),
        _buildFilterChips(tasks),
      ],
    );
  }

  Widget _buildFilterChips(List<CalendarTaskEntity> tasks) {
    final now = DateTime.now();
    final pendingCount = tasks
        .where(
          (t) =>
              !t.isCompleted &&
              !DateTimeUtils.isOverdue(t.dueDate, isCompleted: false),
        )
        .length;
    final completedCount = tasks.where((t) => t.isCompleted).length;

    return SizedBox(
      height: 32.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          HomeCountedFilterPill(
            label: 'All',
            count: tasks.length,
            selected: _selectedFilter == 'all',
            onTap: () => setState(() => _selectedFilter = 'all'),
          ),
          HomeCountedFilterPill(
            label: 'Pending',
            count: pendingCount,
            selected: _selectedFilter == 'pending',
            onTap: () => setState(() => _selectedFilter = 'pending'),
          ),
          HomeCountedFilterPill(
            label: 'Done',
            count: completedCount,
            selected: _selectedFilter == 'completed',
            onTap: () => setState(() => _selectedFilter = 'completed'),
          ),
          if (tasks.any(
            (t) => DateTimeUtils.isOverdue(
              t.dueDate,
              isCompleted: t.isCompleted,
            ),
          ))
            HomeCountedFilterPill(
              label: 'Overdue',
              count: tasks
                  .where(
              (t) => DateTimeUtils.isOverdue(
                t.dueDate,
                isCompleted: t.isCompleted,
              ),
            )
                  .length,
              selected: _selectedFilter == 'overdue',
              onTap: () => setState(() => _selectedFilter = 'overdue'),
            ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(
    CalendarTaskEntity task,
    ThemeData theme,
    bool isDark,
    BuildContext context,
  ) {
    final now = DateTime.now();
    final isOverdue = DateTimeUtils.isOverdue(
      task.dueDate,
      isCompleted: task.isCompleted,
    );
    final priorityColor = _getPriorityColor(task.priority);

    return GestureDetector(
      onTap: () => _navigateToTaskDetails(context, task),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color:
                isOverdue
                    ? Colors.red.withOpacity(0.4)
                    : priorityColor.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow:
              isDark
                  ? []
                  : [
                    BoxShadow(
                      color:
                          isOverdue
                              ? Colors.red.withOpacity(0.08)
                              : priorityColor.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
        ),
        child: Row(
          children: [
            // Status/Priority indicator
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: (isOverdue ? Colors.red : priorityColor).withOpacity(
                  0.1,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                task.isCompleted
                    ? AppIcons.check_circle_rounded
                    : isOverdue
                    ? AppIcons.warning_amber_rounded
                    : AppIcons.task_alt_rounded,
                color: isOverdue ? Colors.red : priorityColor,
                size: 20.sp,
              ),
            ),
            SizedBox(width: 14.w),
            // Task info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          task.title,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color:
                                task.isCompleted
                                    ? theme.colorScheme.secondary
                                    : theme.colorScheme.onSurface,
                            decoration:
                                task.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isOverdue)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          margin: EdgeInsets.only(left: 8.w),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            'Overdue',
                            style: TextStyle(
                              fontSize: 9.sp,
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Icon(
                        AppIcons.access_time_rounded,
                        size: 13.sp,
                        color:
                            isOverdue
                                ? Colors.red
                                : theme.colorScheme.secondary,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'Due: ${DateTimeUtils.formatCalendarDue(task.dueDate)}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color:
                              isOverdue
                                  ? Colors.red
                                  : theme.colorScheme.secondary,
                          fontWeight:
                              isOverdue ? FontWeight.w500 : FontWeight.normal,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: priorityColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          task.priority.toUpperCase(),
                          style: TextStyle(
                            fontSize: 9.sp,
                            color: priorityColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            // Navigation arrow
            Icon(
              AppIcons.chevron_right_rounded,
              color: theme.colorScheme.secondary.withOpacity(0.4),
              size: 22.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventsList(
    DayEventsEntity? selectedDayEvents,
    ThemeData theme,
    bool isDark,
    BuildContext context,
  ) {
    final tasks = selectedDayEvents?.tasks ?? [];
    final reminders = selectedDayEvents?.reminders ?? [];
    final googleEvents = selectedDayEvents?.googleEvents ?? [];

    final filteredTasks = _getFilteredTasks(tasks);
    final hasAnyEvents =
        filteredTasks.isNotEmpty ||
        reminders.isNotEmpty ||
        (_showGoogleEvents && googleEvents.isNotEmpty);

    if (!hasAnyEvents) {
      return _buildEmptyState(
        theme,
        isDark,
      ).animate().fadeIn(duration: 400.ms, delay: 300.ms);
    }

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: [
        // Google Calendar Events (if showing)
        if (_showGoogleEvents && googleEvents.isNotEmpty) ...[
          Padding(
            padding: EdgeInsets.only(bottom: 8.h, top: 4.h),
            child: Row(
              children: [
                Icon(
                  AppIcons.calendar_month_rounded,
                  size: 14.sp,
                  color: Colors.blue,
                ),
                SizedBox(width: 6.w),
                Text(
                  'Google Calendar & Meet',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(width: 6.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    '${googleEvents.length}',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...googleEvents.asMap().entries.map(
            (entry) => _buildGoogleEventCard(entry.value, theme, isDark)
                .animate(delay: (entry.key * 80).ms)
                .fadeIn(duration: 300.ms)
                .slideX(begin: 0.1, end: 0),
          ),
          if (filteredTasks.isNotEmpty || reminders.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Divider(color: theme.dividerColor.withOpacity(0.3)),
            ),
        ],

        // Tasks section
        if (filteredTasks.isNotEmpty) ...[
          Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: Row(
              children: [
                Icon(
                  AppIcons.task_alt_rounded,
                  size: 14.sp,
                  color: theme.colorScheme.primary,
                ),
                SizedBox(width: 6.w),
                Text(
                  'Tasks',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          ...filteredTasks.asMap().entries.map(
            (entry) => _buildTaskCard(entry.value, theme, isDark, context)
                .animate(delay: (entry.key * 80).ms)
                .fadeIn(duration: 300.ms)
                .slideX(begin: 0.1, end: 0),
          ),
        ],

        // Reminders section
        ...reminders.map(
          (reminder) => _buildEventCard(
            reminder.title,
            'Reminder: ${DateFormat('hh:mm a').format(reminder.reminderTime)}',
            Colors.purple,
            theme,
            isDark,
            AppIcons.notifications_active_outlined,
          ),
        ),

        SizedBox(height: 100.h), // Space for bottom nav
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 300.ms);
  }

  Widget _buildEmptyState(ThemeData theme, bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(24.r),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            AppIcons.event_available_outlined,
            size: 48.sp,
            color: theme.colorScheme.primary.withOpacity(0.5),
          ),
        ),
        SizedBox(height: 20.h),
        Text(
          _selectedFilter == 'all'
              ? 'No tasks scheduled'
              : 'No ${_selectedFilter} tasks',
          style: TextStyle(
            fontSize: 18.sp,
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          _selectedFilter == 'all'
              ? 'Tap + to add a new task'
              : 'Try changing the filter',
          style: TextStyle(fontSize: 14.sp, color: theme.colorScheme.secondary),
        ),
        if (_selectedFilter != 'all') ...[
          SizedBox(height: 16.h),
          TextButton.icon(
            onPressed: () {
              setState(() {
                _selectedFilter = 'all';
              });
            },
            icon: Icon(AppIcons.filter_alt_off, size: 18.sp),
            label: const Text('Clear filter'),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.primary,
            ),
          ),
        ],
      ],
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

  Widget _buildEventCard(
    String title,
    String time,
    Color color,
    ThemeData theme,
    bool isDark,
    IconData icon,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
        boxShadow:
            isDark
                ? []
                : [
                  BoxShadow(
                    color: color.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            AppIcons.chevron_right,
            color: theme.colorScheme.secondary.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildGoogleEventCard(
    GoogleCalendarEventEntity event,
    ThemeData theme,
    bool isDark,
  ) {
    final startTime =
        event.startTime != null
            ? DateFormat('hh:mm a').format(event.startTime!)
            : 'All day';
    final endTime =
        event.endTime != null
            ? DateFormat('hh:mm a').format(event.endTime!)
            : '';
    final timeText = endTime.isNotEmpty ? '$startTime - $endTime' : startTime;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.blue.withOpacity(0.3), width: 1.5),
        boxShadow:
            isDark
                ? []
                : [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
      ),
      child: Row(
        children: [
          // Google Calendar indicator
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              AppIcons.event_note_rounded,
              color: Colors.blue,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 14.w),
          // Event info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        event.title,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            AppIcons.calendar_month_rounded,
                            size: 10.sp,
                            color: Colors.blue,
                          ),
                          SizedBox(width: 3.w),
                          Text(
                            'Google',
                            style: TextStyle(
                              fontSize: 9.sp,
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Icon(
                      AppIcons.access_time_rounded,
                      size: 13.sp,
                      color: theme.colorScheme.secondary,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      timeText,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                    if (event.location != null &&
                        event.location!.isNotEmpty) ...[
                      SizedBox(width: 10.w),
                      Icon(
                        AppIcons.location_on_outlined,
                        size: 13.sp,
                        color: theme.colorScheme.secondary,
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Text(
                          event.location!,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: theme.colorScheme.secondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (event.meetLink != null) ...[
            SizedBox(width: 8.w),
            GestureDetector(
              onTap: () async {
                final uri = Uri.parse(event.meetLink!);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              child: Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  AppIcons.videocam_rounded,
                  color: Colors.green,
                  size: 18.sp,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCalendarIntegrationsBanner(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    CalendarLoaded state,
  ) {
    final isGoogleConnected = state.googleStatus?.isConnected ?? false;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: theme.dividerColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Calendar Integrations',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 12.h),
          _buildIntegrationCard(
            context: context,
            theme: theme,
            isDark: isDark,
            title: 'Google Calendar',
            icon: AppIcons.calendar_month_rounded,
            color: Colors.green,
            isConnected: isGoogleConnected,
            onConnect: () => _connectGoogleCalendar(context),
            onTap: () => _showGoogleCalendarMenu(context, theme, isDark),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildIntegrationCard({
    required BuildContext context,
    required ThemeData theme,
    required bool isDark,
    required String title,
    required IconData icon,
    required Color color,
    required bool isConnected,
    required VoidCallback onConnect,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: isConnected ? onTap : onConnect,
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color:
              isConnected
                  ? color.withOpacity(0.1)
                  : isDark
                  ? Colors.white.withOpacity(0.03)
                  : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color:
                isConnected
                    ? color.withOpacity(0.3)
                    : theme.dividerColor.withOpacity(0.2),
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  icon,
                  color: isConnected ? color : theme.colorScheme.secondary,
                  size: 20.sp,
                ),
                if (isConnected)
                  Icon(AppIcons.check_circle, color: color, size: 16.sp)
                else
                  Icon(
                    AppIcons.add_circle_outline,
                    color: theme.colorScheme.secondary,
                    size: 16.sp,
                  ),
              ],
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: isConnected ? color : theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Row(
              children: [
                Text(
                  isConnected ? 'Connected' : 'Tap to connect',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoogleCalendarBanner(
    BuildContext context,
    ThemeData theme,
    bool isDark,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.withOpacity(0.1),
            Colors.green.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              AppIcons.calendar_month_rounded,
              color: Colors.blue,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Connect Google Calendar',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Sync Google Calendar meetings and Meet links',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _connectGoogleCalendar(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            ),
            child: Text(
              'Connect',
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildTodayMeetingsSection(
    List<GoogleCalendarEventEntity> meetings,
    ThemeData theme,
    bool isDark,
  ) {
    if (meetings.isEmpty || !_showGoogleEvents) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            children: [
              Icon(AppIcons.videocam_rounded, color: Colors.green, size: 18.sp),
              SizedBox(width: 8.w),
              Text(
                "Today's Meetings",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  '${meetings.length}',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8.h),
        SizedBox(
          height: 80.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            physics: const BouncingScrollPhysics(),
            itemCount: meetings.length,
            itemBuilder: (ctx, index) {
              final meeting = meetings[index];
              return Container(
                    width: 200.w,
                    margin: EdgeInsets.only(right: 12.w),
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.green.withOpacity(0.1),
                          Colors.blue.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: Colors.green.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          meeting.title,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            Icon(
                              AppIcons.access_time_rounded,
                              size: 12.sp,
                              color: theme.colorScheme.secondary,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              meeting.startTime != null
                                  ? DateFormat(
                                    'hh:mm a',
                                  ).format(meeting.startTime!)
                                  : 'All day',
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: theme.colorScheme.secondary,
                              ),
                            ),
                            if (meeting.meetLink != null) ...[
                              const Spacer(),
                              Icon(
                                AppIcons.videocam_rounded,
                                size: 14.sp,
                                color: Colors.green,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  )
                  .animate(delay: (index * 100).ms)
                  .fadeIn()
                  .slideX(begin: 0.2, end: 0);
            },
          ),
        ),
        SizedBox(height: 12.h),
      ],
    );
  }
}
