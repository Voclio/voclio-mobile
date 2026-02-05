import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

class MonthlyCalendarScreen extends StatelessWidget {
  const MonthlyCalendarScreen({super.key});

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
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String _selectedFilter = 'all'; // all, pending, completed, overdue
  bool _showGoogleEvents = true; // Toggle for showing Google Calendar events

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    // Check Google Calendar status on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CalendarCubit>().checkGoogleCalendarStatus();
    });
  }

  void _showAddTaskSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocProvider.value(
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

  void _navigateToTaskDetails(BuildContext context, CalendarTaskEntity calendarTask) {
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
        builder: (_) => BlocProvider.value(
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
    final urlEntity = await cubit.getGoogleConnectUrl();
    
    if (urlEntity != null && urlEntity.authUrl.isNotEmpty) {
      final uri = Uri.parse(urlEntity.authUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open Google sign-in')),
          );
        }
      }
    }
  }

  Future<void> _disconnectGoogleCalendar(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Disconnect Google Calendar?'),
        content: const Text(
          'This will remove the Google Calendar sync. Your Google events will no longer appear in the calendar.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Disconnect'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<CalendarCubit>().disconnectGoogleCalendar();
    }
  }

  Future<void> _connectWebex(BuildContext context) async {
    final cubit = context.read<CalendarCubit>();
    final urlEntity = await cubit.getWebexConnectUrl();
    
    if (urlEntity != null && urlEntity.authUrl.isNotEmpty) {
      final uri = Uri.parse(urlEntity.authUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open Webex sign-in')),
          );
        }
      }
    }
  }

  Future<void> _disconnectWebex(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Disconnect Webex?'),
        content: const Text(
          'This will remove the Webex sync. Your Webex meetings will no longer appear in the calendar.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Disconnect'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<CalendarCubit>().disconnectWebex();
    }
  }

  void _showGoogleCalendarMenu(BuildContext context, ThemeData theme, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) => Padding(
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
                    Icons.event_available,
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
                _showGoogleEvents ? Icons.visibility : Icons.visibility_off,
                color: theme.colorScheme.primary,
              ),
              title: Text(_showGoogleEvents ? 'Hide Google Events' : 'Show Google Events'),
              onTap: () {
                setState(() {
                  _showGoogleEvents = !_showGoogleEvents;
                });
                Navigator.pop(ctx);
              },
            ),
            // Refresh events
            ListTile(
              leading: Icon(Icons.refresh, color: theme.colorScheme.primary),
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
              leading: const Icon(Icons.link_off, color: Colors.red),
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

  void _showWebexMenu(BuildContext context, ThemeData theme, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) => Padding(
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
                    color: Colors.blue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.video_call,
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
                        'Webex Connected',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Your meetings are syncing',
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
            // Refresh meetings
            ListTile(
              leading: Icon(Icons.refresh, color: theme.colorScheme.primary),
              title: const Text('Refresh Meetings'),
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
              leading: const Icon(Icons.link_off, color: Colors.red),
              title: const Text(
                'Disconnect Webex',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _disconnectWebex(context);
              },
            ),
            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }

  List<CalendarTaskEntity> _getFilteredTasks(List<CalendarTaskEntity> tasks) {
    final now = DateTime.now();
    switch (_selectedFilter) {
      case 'pending':
        return tasks.where((t) => !t.isCompleted).toList();
      case 'completed':
        return tasks.where((t) => t.isCompleted).toList();
      case 'overdue':
        return tasks.where((t) => !t.isCompleted && t.dueDate.isBefore(now)).toList();
      default:
        return tasks;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Calendar',
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        actions: [
          // Google Calendar toggle
          BlocBuilder<CalendarCubit, CalendarState>(
            buildWhen: (prev, curr) =>
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
                  color: isConnected
                      ? Colors.green.withOpacity(0.15)
                      : isDark
                          ? Colors.white10
                          : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: IconButton(
                  icon: Icon(
                    isConnected ? Icons.event_available : Icons.event_busy,
                    color: isConnected ? Colors.green : theme.colorScheme.secondary,
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
          // Webex toggle
          BlocBuilder<CalendarCubit, CalendarState>(
            buildWhen: (prev, curr) =>
                curr is WebexConnected ||
                curr is WebexDisconnected ||
                curr is CalendarLoaded,
            builder: (context, state) {
              bool isConnected = false;
              if (state is CalendarLoaded) {
                isConnected = state.webexStatus?.isConnected ?? false;
              } else if (state is WebexConnected) {
                isConnected = true;
              }

              return Container(
                margin: EdgeInsets.only(right: 4.w),
                decoration: BoxDecoration(
                  color: isConnected
                      ? Colors.blue.withOpacity(0.15)
                      : isDark
                          ? Colors.white10
                          : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: IconButton(
                  icon: Icon(
                    isConnected ? Icons.video_call : Icons.video_call_outlined,
                    color: isConnected ? Colors.blue : theme.colorScheme.secondary,
                    size: 18.sp,
                  ),
                  onPressed: () {
                    if (isConnected) {
                      _showWebexMenu(context, theme, isDark);
                    } else {
                      _connectWebex(context);
                    }
                  },
                  tooltip: isConnected ? 'Webex Connected' : 'Connect Webex',
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
                    ? Icons.calendar_view_week
                    : _calendarFormat == CalendarFormat.twoWeeks
                        ? Icons.calendar_view_day
                        : Icons.calendar_month,
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
                Icons.today,
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
                  Icon(Icons.error_outline, size: 48.sp, color: Colors.red),
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
                          todayDecoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          todayTextStyle: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                          selectedDecoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          markerDecoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          markersMaxCount: 1,
                          outsideDaysVisible: false,
                          defaultTextStyle: TextStyle(
                            color: theme.colorScheme.onSurface,
                          ),
                          weekendTextStyle: TextStyle(
                            color: theme.colorScheme.primary.withOpacity(0.7),
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

                // Selected Day info with filter chips
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isSameDay(effectiveSelection, DateTime.now())
                                ? 'Today\'s Tasks'
                                : 'Tasks for ${DateFormat('MMM d').format(effectiveSelection)}',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.sp,
                            ),
                          ),
                          if (selectedDayEvents != null &&
                              selectedDayEvents.count > 0)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Text(
                                '${_getFilteredTasks(selectedDayEvents.tasks).length}/${selectedDayEvents.count}',
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (selectedDayEvents != null && selectedDayEvents.tasks.isNotEmpty) ...[
                        SizedBox(height: 12.h),
                        _buildFilterChips(theme, isDark, selectedDayEvents.tasks),
                      ],
                    ],
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: 200.ms),

                SizedBox(height: 12.h),

                // Today's meetings section (if connected and it's today)
                if (isSameDay(effectiveSelection, DateTime.now()) &&
                    state.todayMeetings != null &&
                    state.todayMeetings!.isNotEmpty)
                  _buildTodayMeetingsSection(state.todayMeetings!, theme, isDark),

                // Calendar integrations banner (if not all connected)
                if ((state.googleStatus == null || !state.googleStatus!.isConnected) ||
                    (state.webexStatus == null || !state.webexStatus!.isConnected))
                  _buildCalendarIntegrationsBanner(context, theme, isDark, state),

                // Events List
                _buildEventsList(
                  selectedDayEvents,
                  theme,
                  isDark,
                  context,
                ),
                
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

  Widget _buildFilterChips(ThemeData theme, bool isDark, List<CalendarTaskEntity> tasks) {
    final now = DateTime.now();
    final pendingCount = tasks.where((t) => !t.isCompleted).length;
    final completedCount = tasks.where((t) => t.isCompleted).length;
    final overdueCount = tasks.where((t) => !t.isCompleted && t.dueDate.isBefore(now)).length;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildFilterChip('All', 'all', tasks.length, theme, isDark),
          SizedBox(width: 8.w),
          _buildFilterChip('Pending', 'pending', pendingCount, theme, isDark,
              color: Colors.orange),
          SizedBox(width: 8.w),
          _buildFilterChip('Done', 'completed', completedCount, theme, isDark,
              color: Colors.green),
          if (overdueCount > 0) ...[
            SizedBox(width: 8.w),
            _buildFilterChip('Overdue', 'overdue', overdueCount, theme, isDark,
                color: Colors.red),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    String value,
    int count,
    ThemeData theme,
    bool isDark, {
    Color? color,
  }) {
    final isSelected = _selectedFilter == value;
    final chipColor = color ?? theme.colorScheme.primary;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isSelected
              ? chipColor.withOpacity(0.15)
              : isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? chipColor : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? chipColor : theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(width: 4.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? chipColor.withOpacity(0.2)
                    : theme.colorScheme.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? chipColor : theme.colorScheme.secondary,
                ),
              ),
            ),
          ],
        ),
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
    final isOverdue = !task.isCompleted && task.dueDate.isBefore(now);
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
            color: isOverdue
                ? Colors.red.withOpacity(0.4)
                : priorityColor.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: isOverdue
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
                color: (isOverdue ? Colors.red : priorityColor).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                task.isCompleted
                    ? Icons.check_circle_rounded
                    : isOverdue
                        ? Icons.warning_amber_rounded
                        : Icons.task_alt_rounded,
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
                            color: task.isCompleted
                                ? theme.colorScheme.secondary
                                : theme.colorScheme.onSurface,
                            decoration:
                                task.isCompleted ? TextDecoration.lineThrough : null,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isOverdue)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
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
                        Icons.access_time_rounded,
                        size: 13.sp,
                        color: isOverdue ? Colors.red : theme.colorScheme.secondary,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'Due: ${DateFormat('hh:mm a').format(task.dueDate)}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: isOverdue ? Colors.red : theme.colorScheme.secondary,
                          fontWeight: isOverdue ? FontWeight.w500 : FontWeight.normal,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
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
              Icons.chevron_right_rounded,
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
    final hasAnyEvents = filteredTasks.isNotEmpty ||
        reminders.isNotEmpty ||
        (_showGoogleEvents && googleEvents.isNotEmpty);

    if (!hasAnyEvents) {
      return _buildEmptyState(theme, isDark).animate().fadeIn(duration: 400.ms, delay: 300.ms);
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
                  Icons.calendar_month_rounded,
                  size: 14.sp,
                  color: Colors.blue,
                ),
                SizedBox(width: 6.w),
                Text(
                  'Google Calendar',
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
                  Icons.task_alt_rounded,
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
            (entry) => _buildTaskCard(
              entry.value,
              theme,
              isDark,
              context,
            ).animate(delay: (entry.key * 80).ms)
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
            Icons.notifications_active_outlined,
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
            Icons.event_available_outlined,
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
          style: TextStyle(
            fontSize: 14.sp,
            color: theme.colorScheme.secondary,
          ),
        ),
        if (_selectedFilter != 'all') ...[
          SizedBox(height: 16.h),
          TextButton.icon(
            onPressed: () {
              setState(() {
                _selectedFilter = 'all';
              });
            },
            icon: Icon(Icons.filter_alt_off, size: 18.sp),
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
            Icons.chevron_right,
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
    final startTime = event.startTime != null
        ? DateFormat('hh:mm a').format(event.startTime!)
        : 'All day';
    final endTime = event.endTime != null
        ? DateFormat('hh:mm a').format(event.endTime!)
        : '';
    final timeText = endTime.isNotEmpty ? '$startTime - $endTime' : startTime;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: Colors.blue.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: isDark
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
              Icons.event_note_rounded,
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
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.calendar_month_rounded,
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
                      Icons.access_time_rounded,
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
                    if (event.location != null && event.location!.isNotEmpty) ...[
                      SizedBox(width: 10.w),
                      Icon(
                        Icons.location_on_outlined,
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
                  Icons.videocam_rounded,
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
    final isWebexConnected = state.webexStatus?.isConnected ?? false;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.3),
        ),
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
          Row(
            children: [
              // Google Calendar
              Expanded(
                child: _buildIntegrationCard(
                  context: context,
                  theme: theme,
                  isDark: isDark,
                  title: 'Google',
                  icon: Icons.calendar_month_rounded,
                  color: Colors.green,
                  isConnected: isGoogleConnected,
                  onConnect: () => _connectGoogleCalendar(context),
                  onTap: () => _showGoogleCalendarMenu(context, theme, isDark),
                ),
              ),
              SizedBox(width: 12.w),
              // Webex
              Expanded(
                child: _buildIntegrationCard(
                  context: context,
                  theme: theme,
                  isDark: isDark,
                  title: 'Webex',
                  icon: Icons.video_call_rounded,
                  color: Colors.blue,
                  isConnected: isWebexConnected,
                  onConnect: () => _connectWebex(context),
                  onTap: () => _showWebexMenu(context, theme, isDark),
                ),
              ),
            ],
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
          color: isConnected
              ? color.withOpacity(0.1)
              : isDark
                  ? Colors.white.withOpacity(0.03)
                  : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isConnected ? color.withOpacity(0.3) : theme.dividerColor.withOpacity(0.2),
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
                  Icon(
                    Icons.check_circle,
                    color: color,
                    size: 16.sp,
                  )
                else
                  Icon(
                    Icons.add_circle_outline,
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
        border: Border.all(
          color: Colors.blue.withOpacity(0.2),
        ),
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
              Icons.calendar_month_rounded,
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
                  'Sync your meetings and events',
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
              Icon(
                Icons.videocam_rounded,
                color: Colors.green,
                size: 18.sp,
              ),
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
                  border: Border.all(
                    color: Colors.green.withOpacity(0.2),
                  ),
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
                          Icons.access_time_rounded,
                          size: 12.sp,
                          color: theme.colorScheme.secondary,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          meeting.startTime != null
                              ? DateFormat('hh:mm a').format(meeting.startTime!)
                              : 'All day',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                        if (meeting.meetLink != null) ...[
                          const Spacer(),
                          Icon(
                            Icons.videocam_rounded,
                            size: 14.sp,
                            color: Colors.green,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ).animate(delay: (index * 100).ms).fadeIn().slideX(begin: 0.2, end: 0);
            },
          ),
        ),
        SizedBox(height: 12.h),
      ],
    );
  }
}
