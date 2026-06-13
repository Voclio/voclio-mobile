import '../../domain/entities/calendar_month_entity.dart';
import '../../domain/entities/google_calendar_entity.dart';
import '../../../../core/utils/date_time_utils.dart';

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
    super.googleEventsCount = 0,
    super.googleSyncEnabled = false,
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
      googleEventsCount: data['google_events_count'] ?? 0,
      googleSyncEnabled: data['google_sync_enabled'] ?? false,
    );
  }
}

class DayEventsModel extends DayEventsEntity {
  const DayEventsModel({
    required super.tasks,
    required super.reminders,
    super.googleEvents = const [],
    required super.count,
  });

  factory DayEventsModel.fromJson(Map<String, dynamic> json) {
    final googleEventsRaw =
        json['google_events'] ?? json['meetings'] as List<dynamic>?;

    return DayEventsModel(
      tasks: List<CalendarTaskEntity>.from(
        (json['tasks'] as List<dynamic>? ?? const []).map(
          (e) => CalendarTaskModel.fromJson(e as Map<String, dynamic>),
        ),
      ),
      reminders: List<CalendarReminderEntity>.from(
        (json['reminders'] as List<dynamic>? ?? const []).map(
          (e) => CalendarReminderModel.fromJson(e as Map<String, dynamic>),
        ),
      ),
      googleEvents: List<GoogleCalendarEventEntity>.from(
        (googleEventsRaw as List<dynamic>? ?? const []).map(
          (e) => GoogleCalendarEventModel.fromJson(
            Map<String, dynamic>.from(e as Map),
          ),
        ),
      ),
      count: json['count'] ?? 0,
    );
  }
}

class GoogleCalendarEventModel extends GoogleCalendarEventEntity {
  const GoogleCalendarEventModel({
    required super.id,
    required super.title,
    super.description,
    required super.startTime,
    required super.endTime,
    super.location,
    super.attendees = const [],
    super.htmlLink,
    super.meetLink,
    super.isAllDay = false,
    super.colorId,
  });

  factory GoogleCalendarEventModel.fromJson(Map<String, dynamic> json) {
    return GoogleCalendarEventModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? json['summary'] ?? 'Untitled Event',
      description: json['description']?.toString(),
      startTime: _parseDateTime(json['start'] ?? json['startTime']),
      endTime: _parseDateTime(json['end'] ?? json['endTime']),
      location: json['location']?.toString(),
      attendees:
          (json['attendees'] as List<dynamic>?)
              ?.map((a) => a is Map ? (a['email']?.toString() ?? '') : a.toString())
              .where((email) => email.isNotEmpty)
              .toList() ??
          [],
      htmlLink: json['htmlLink']?.toString(),
      meetLink: json['meet_link']?.toString() ?? json['meetLink']?.toString(),
      isAllDay: json['isAllDay'] == true || json['is_all_day'] == true,
      colorId: json['colorId']?.toString(),
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) return DateTime.parse(value);
    if (value is Map) {
      final dateTimeStr = value['dateTime'] ?? value['date'];
      if (dateTimeStr != null) return DateTime.parse(dateTimeStr);
    }
    return DateTime.now();
  }
}

class CalendarTaskModel extends CalendarTaskEntity {
  const CalendarTaskModel({
    required super.id,
    required super.title,
    super.description,
    required super.priority,
    required super.status,
    required super.dueDate,
  });

  factory CalendarTaskModel.fromJson(Map<String, dynamic> json) {
    return CalendarTaskModel(
      id: json['task_id'],
      title: json['title'],
      description: json['description']?.toString(),
      priority: json['priority'],
      status: json['status'],
      dueDate: DateTimeUtils.parseApi(json['due_date']),
    );
  }
}

class CalendarReminderModel extends CalendarReminderEntity {
  const CalendarReminderModel({
    required super.id,
    required super.title,
    required super.reminderTime,
    super.taskId,
  });

  factory CalendarReminderModel.fromJson(Map<String, dynamic> json) {
    return CalendarReminderModel(
      id: json['reminder_id'] ?? 0,
      title: json['title'] ?? '',
      reminderTime: DateTime.parse(
        json['reminder_time'] ?? DateTime.now().toIso8601String(),
      ),
      taskId: json['task_id'] as int?,
    );
  }
}
