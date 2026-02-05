import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../tasks/domain/entities/task_entity.dart';
import '../../../tasks/presentation/screens/task_details_screen.dart';
import '../../../tasks/presentation/bloc/tasks_cubit.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  String _selectedFilter = 'all'; // all, pending, completed, overdue

  // Mock data - will be replaced with actual data from cubit
  final Map<DateTime, List<TaskEntity>> _events = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  List<TaskEntity> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  List<TaskEntity> _getFilteredEvents(List<TaskEntity> events) {
    final now = DateTime.now();
    switch (_selectedFilter) {
      case 'pending':
        return events.where((t) => !t.isDone).toList();
      case 'completed':
        return events.where((t) => t.isDone).toList();
      case 'overdue':
        return events.where((t) => !t.isDone && t.date.isBefore(now)).toList();
      default:
        return events;
    }
  }

  void _navigateToTaskDetails(BuildContext context, TaskEntity task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => BlocProvider.value(
              value: context.read<TasksCubit>(),
              child: TaskDetailScreen(task: task),
            ),
      ),
    );
  }

  void _showDayEvents(DateTime day) {
    final events = _getEventsForDay(day);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildEventBottomSheet(day, events),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(
              theme,
              isDark,
            ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2, end: 0),

            // Calendar
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                child: Column(
                  children: [
                    _buildCalendar(theme, isDark)
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 200.ms)
                        .scale(begin: const Offset(0.95, 0.95)),

                    SizedBox(height: 20.h),

                    // Today's Events
                    _buildTodayEvents(theme, isDark)
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 400.ms)
                        .slideY(begin: 0.2, end: 0),

                    SizedBox(height: 100.h), // Space for bottom nav
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, bool isDark) {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Calendar',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                DateFormat('MMMM yyyy').format(_focusedDay),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.secondary,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
          Row(
            children: [
              // Format toggle button
              Container(
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
              SizedBox(width: 8.w),
              Container(
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: IconButton(
                  icon: Icon(Icons.today, color: theme.colorScheme.onSurface),
                  onPressed: () {
                    setState(() {
                      _focusedDay = DateTime.now();
                      _selectedDay = DateTime.now();
                    });
                  },
                  tooltip: 'Go to today',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar(ThemeData theme, bool isDark) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
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
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        calendarFormat: _calendarFormat,
        eventLoader: _getEventsForDay,
        startingDayOfWeek: StartingDayOfWeek.sunday,
        calendarStyle: CalendarStyle(
          // Today
          todayDecoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          todayTextStyle: TextStyle(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
          // Selected
          selectedDecoration: BoxDecoration(
            color: theme.colorScheme.primary,
            shape: BoxShape.circle,
          ),
          selectedTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          // Default
          defaultTextStyle: TextStyle(color: theme.colorScheme.onSurface),
          weekendTextStyle: TextStyle(
            color: theme.colorScheme.primary.withOpacity(0.7),
          ),
          outsideTextStyle: TextStyle(
            color: theme.colorScheme.secondary.withOpacity(0.3),
          ),
          // Markers
          markerDecoration: BoxDecoration(
            color: theme.colorScheme.primary,
            shape: BoxShape.circle,
          ),
          markersMaxCount: 3,
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
          leftChevronIcon: Icon(
            Icons.chevron_left,
            color: theme.colorScheme.onSurface,
          ),
          rightChevronIcon: Icon(
            Icons.chevron_right,
            color: theme.colorScheme.onSurface,
          ),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            color: theme.colorScheme.secondary,
            fontWeight: FontWeight.w600,
          ),
          weekendStyle: TextStyle(
            color: theme.colorScheme.primary.withOpacity(0.7),
            fontWeight: FontWeight.w600,
          ),
        ),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
          _showDayEvents(selectedDay);
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
      ),
    );
  }

  Widget _buildTodayEvents(ThemeData theme, bool isDark) {
    final todayEvents = _getEventsForDay(_selectedDay ?? DateTime.now());
    final filteredEvents = _getFilteredEvents(todayEvents);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _selectedDay != null && isSameDay(_selectedDay, DateTime.now())
                    ? 'Today\'s Events'
                    : 'Events for ${DateFormat('MMM d').format(_selectedDay ?? DateTime.now())}',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (todayEvents.isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    '${filteredEvents.length}/${todayEvents.length}',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 12.h),
          // Filter chips
          if (todayEvents.isNotEmpty) ...[
            _buildFilterChips(theme, isDark, todayEvents),
            SizedBox(height: 16.h),
          ],
          filteredEvents.isEmpty
              ? _buildEmptyState(theme, isDark)
              : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredEvents.length,
                itemBuilder: (context, index) {
                  return _buildEventCard(filteredEvents[index], theme, isDark)
                      .animate(delay: (index * 100).ms)
                      .fadeIn(duration: 400.ms)
                      .slideX(begin: 0.2, end: 0);
                },
              ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(
    ThemeData theme,
    bool isDark,
    List<TaskEntity> events,
  ) {
    final now = DateTime.now();
    final pendingCount = events.where((t) => !t.isDone).length;
    final completedCount = events.where((t) => t.isDone).length;
    final overdueCount =
        events.where((t) => !t.isDone && t.date.isBefore(now)).length;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildFilterChip('All', 'all', events.length, theme, isDark),
          SizedBox(width: 8.w),
          _buildFilterChip(
            'Pending',
            'pending',
            pendingCount,
            theme,
            isDark,
            color: Colors.orange,
          ),
          SizedBox(width: 8.w),
          _buildFilterChip(
            'Completed',
            'completed',
            completedCount,
            theme,
            isDark,
            color: Colors.green,
          ),
          SizedBox(width: 8.w),
          if (overdueCount > 0)
            _buildFilterChip(
              'Overdue',
              'overdue',
              overdueCount,
              theme,
              isDark,
              color: Colors.red,
            ),
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
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? chipColor.withOpacity(0.15)
                  : isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20.r),
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
                fontSize: 13.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? chipColor : theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(width: 6.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              decoration: BoxDecoration(
                color:
                    isSelected
                        ? chipColor.withOpacity(0.2)
                        : theme.colorScheme.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 11.sp,
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

  Widget _buildEmptyState(ThemeData theme, bool isDark) {
    final isToday =
        _selectedDay != null && isSameDay(_selectedDay, DateTime.now());

    return Container(
      padding: EdgeInsets.all(40.r),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: theme.colorScheme.secondary.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isToday ? Icons.today_outlined : Icons.event_available_outlined,
              size: 48.sp,
              color: theme.colorScheme.primary.withOpacity(0.6),
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
                ? 'Tap the + button to add a new task'
                : 'Try changing the filter to see more tasks',
            style: TextStyle(
              fontSize: 14.sp,
              color: theme.colorScheme.secondary.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
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
              label: Text('Clear filter'),
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEventCard(TaskEntity task, ThemeData theme, bool isDark) {
    final now = DateTime.now();
    final isOverdue = !task.isDone && task.date.isBefore(now);
    final hasSubtasks = task.subtasks.isNotEmpty;

    return GestureDetector(
      onTap: () => _navigateToTaskDetails(context, task),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color:
                isOverdue
                    ? Colors.red.withOpacity(0.4)
                    : task.priority.color.withOpacity(0.3),
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
                              : task.priority.color.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
        ),
        child: Row(
          children: [
            // Priority/Status indicator
            Container(
              width: 4.w,
              height: 50.h,
              decoration: BoxDecoration(
                color: isOverdue ? Colors.red : task.priority.color,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(width: 12.w),
            // Checkbox
            GestureDetector(
              onTap: () {
                // Toggle task status without navigating
              },
              child: Container(
                width: 26.w,
                height: 26.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color:
                        task.isDone
                            ? theme.colorScheme.primary
                            : isOverdue
                            ? Colors.red.withOpacity(0.5)
                            : theme.colorScheme.secondary.withOpacity(0.3),
                    width: 2,
                  ),
                  color:
                      task.isDone
                          ? theme.colorScheme.primary
                          : Colors.transparent,
                ),
                child:
                    task.isDone
                        ? Icon(Icons.check, size: 16.sp, color: Colors.white)
                        : null,
              ),
            ),
            SizedBox(width: 12.w),
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
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color:
                                task.isDone
                                    ? theme.colorScheme.secondary
                                    : theme.colorScheme.onSurface,
                            decoration:
                                task.isDone ? TextDecoration.lineThrough : null,
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
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                size: 12.sp,
                                color: Colors.red,
                              ),
                              SizedBox(width: 3.w),
                              Text(
                                'Overdue',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: Colors.red,
                                  fontWeight: FontWeight.w600,
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
                        size: 14.sp,
                        color:
                            isOverdue
                                ? Colors.red
                                : theme.colorScheme.secondary,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'Due: ${DateFormat('hh:mm a').format(task.date)}',
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
                      if (hasSubtasks) ...[
                        SizedBox(width: 12.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.checklist_rounded,
                                size: 12.sp,
                                color: theme.colorScheme.secondary,
                              ),
                              SizedBox(width: 3.w),
                              Text(
                                '${task.completedSubtasks}/${task.totalSubtasks}',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: theme.colorScheme.secondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (task.tags.isNotEmpty) ...[
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            task.tags.first,
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            // Arrow indicator for navigation
            Icon(
              Icons.chevron_right_rounded,
              color: theme.colorScheme.secondary.withOpacity(0.5),
              size: 24.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventBottomSheet(DateTime day, List<TaskEntity> events) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final now = DateTime.now();
    final pendingCount = events.where((t) => !t.isDone).length;
    final completedCount = events.where((t) => t.isDone).length;
    final overdueCount =
        events.where((t) => !t.isDone && t.date.isBefore(now)).length;

    return Container(
      height: 0.75.sh,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        children: [
          // Handle
          SizedBox(height: 12.h),
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 20.h),
          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('EEEE').format(day),
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      DateFormat('MMMM d, yyyy').format(day),
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    if (overdueCount > 0)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 6.h,
                        ),
                        margin: EdgeInsets.only(right: 8.w),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              size: 14.sp,
                              color: Colors.red,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              '$overdueCount',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 12.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        '${events.length} ${events.length == 1 ? 'task' : 'tasks'}',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          // Stats row
          if (events.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                children: [
                  _buildStatChip(
                    'Pending',
                    pendingCount,
                    Colors.orange,
                    isDark,
                  ),
                  SizedBox(width: 8.w),
                  _buildStatChip('Done', completedCount, Colors.green, isDark),
                  if (overdueCount > 0) ...[
                    SizedBox(width: 8.w),
                    _buildStatChip('Overdue', overdueCount, Colors.red, isDark),
                  ],
                ],
              ),
            ),
          SizedBox(height: 16.h),
          Divider(
            height: 1,
            color: theme.colorScheme.secondary.withOpacity(0.1),
          ),
          // Events list
          Expanded(
            child:
                events.isEmpty
                    ? Center(
                      child: Column(
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
                            'No tasks for this day',
                            style: TextStyle(
                              fontSize: 18.sp,
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Tap + to add a new task',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      padding: EdgeInsets.all(20.r),
                      physics: const BouncingScrollPhysics(),
                      itemCount: events.length,
                      itemBuilder: (context, index) {
                        return _buildEventCard(events[index], theme, isDark)
                            .animate(delay: (index * 80).ms)
                            .fadeIn(duration: 300.ms)
                            .slideX(begin: 0.1, end: 0);
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, int count, Color color, bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.15 : 0.1),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8.w,
            height: 8.h,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: 6.w),
          Text(
            '$label: $count',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
