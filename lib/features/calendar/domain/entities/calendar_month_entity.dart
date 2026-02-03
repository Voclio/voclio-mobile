import 'package:equatable/equatable.dart';
import 'google_calendar_entity.dart';

class CalendarMonthEntity extends Equatable {
  final int year;
  final int month;
  final String monthName;
  final int daysInMonth;
  final Map<int, DayEventsEntity> eventsByDay;
  final int totalEvents;
  final int tasksCount;
  final int remindersCount;
  final int googleEventsCount;
  final bool googleSyncEnabled;

  const CalendarMonthEntity({
    required this.year,
    required this.month,
    required this.monthName,
    required this.daysInMonth,
    required this.eventsByDay,
    required this.totalEvents,
    required this.tasksCount,
    required this.remindersCount,
    this.googleEventsCount = 0,
    this.googleSyncEnabled = false,
  });

  @override
  List<Object?> get props => [
    year,
    month,
    monthName,
    daysInMonth,
    eventsByDay,
    totalEvents,
    tasksCount,
    remindersCount,
    googleEventsCount,
    googleSyncEnabled,
  ];
}

class DayEventsEntity extends Equatable {
  final List<CalendarTaskEntity> tasks;
  final List<CalendarReminderEntity> reminders;
  final List<GoogleCalendarEventEntity> googleEvents;
  final int count;

  const DayEventsEntity({
    required this.tasks,
    required this.reminders,
    this.googleEvents = const [],
    required this.count,
  });

  /// Get total count including Google events
  int get totalCount => tasks.length + reminders.length + googleEvents.length;

  @override
  List<Object?> get props => [tasks, reminders, googleEvents, count];
}

class CalendarTaskEntity extends Equatable {
  final int id;
  final String title;
  final String priority;
  final String status;
  final DateTime dueDate;

  bool get isCompleted =>
      status.toLowerCase() == 'completed' || status.toLowerCase() == 'done';

  const CalendarTaskEntity({
    required this.id,
    required this.title,
    required this.priority,
    required this.status,
    required this.dueDate,
  });

  CalendarTaskEntity copyWith({
    int? id,
    String? title,
    String? priority,
    String? status,
    DateTime? dueDate,
  }) {
    return CalendarTaskEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
    );
  }

  @override
  List<Object?> get props => [id, title, priority, status, dueDate];
}

class CalendarReminderEntity extends Equatable {
  final int id;
  final String title;
  final DateTime reminderTime;

  const CalendarReminderEntity({
    required this.id,
    required this.title,
    required this.reminderTime,
  });

  @override
  List<Object?> get props => [id, title, reminderTime];
}
