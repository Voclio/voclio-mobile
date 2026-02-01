import '../../domain/entities/calendar_month_entity.dart';

class CalendarMonthModel extends CalendarMonthEntity {
  const CalendarMonthModel({
    required super.year,
    required super.month,
    required super.monthName,
    required super.daysInMonth,
    required super.eventsByDay,
    required super.totalEvents,
    required super.tasksCount,
    required super.remindersCount,
  });

  factory CalendarMonthModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;

    final eventsByDayRaw = data['events_by_day'] as Map<String, dynamic>? ?? {};
    final Map<int, DayEventsEntity> eventsByDay = {};

    eventsByDayRaw.forEach((key, value) {
      final day = int.tryParse(key);
      if (day != null) {
        eventsByDay[day] = DayEventsModel.fromJson(
          value as Map<String, dynamic>,
        );
      }
    });

    return CalendarMonthModel(
      year: data['year'],
      month: data['month'],
      monthName: data['month_name'],
      daysInMonth: data['days_in_month'],
      eventsByDay: eventsByDay,
      totalEvents: data['total_events'],
      tasksCount: data['tasks_count'],
      remindersCount: data['reminders_count'],
    );
  }
}

class DayEventsModel extends DayEventsEntity {
  const DayEventsModel({
    required super.tasks,
    required super.reminders,
    required super.count,
  });

  factory DayEventsModel.fromJson(Map<String, dynamic> json) {
    return DayEventsModel(
      tasks:
          (json['tasks'] as List<dynamic>?)
              ?.map(
                (e) => CalendarTaskModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      reminders:
          (json['reminders'] as List<dynamic>?)
              ?.map(
                (e) =>
                    CalendarReminderModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      count: json['count'] ?? 0,
    );
  }
}

class CalendarTaskModel extends CalendarTaskEntity {
  const CalendarTaskModel({
    required super.id,
    required super.title,
    required super.priority,
    required super.status,
    required super.dueDate,
  });

  factory CalendarTaskModel.fromJson(Map<String, dynamic> json) {
    return CalendarTaskModel(
      id: json['task_id'],
      title: json['title'],
      priority: json['priority'],
      status: json['status'],
      dueDate: DateTime.parse(json['due_date']),
    );
  }
}

class CalendarReminderModel extends CalendarReminderEntity {
  const CalendarReminderModel({
    required super.id,
    required super.title,
    required super.reminderTime,
  });

  factory CalendarReminderModel.fromJson(Map<String, dynamic> json) {
    return CalendarReminderModel(
      id: json['reminder_id'] ?? 0,
      title: json['title'] ?? '',
      reminderTime: DateTime.parse(
        json['reminder_time'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}
