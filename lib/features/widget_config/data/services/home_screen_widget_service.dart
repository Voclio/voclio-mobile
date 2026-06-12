import 'dart:convert';

import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';
import 'package:voclio_app/features/notes/domain/entities/note_entity.dart';
import 'package:voclio_app/features/tasks/domain/entities/task_entity.dart';

/// Pushes tasks + notes to the native home screen widget (calendar strip + lists).
class HomeScreenWidgetService {
  static const String _appGroupId = 'group.com.example.voclio_app';
  static const String _androidWidgetName = 'VoclioWidgetProvider';
  static const String _iOSWidgetName = 'VoclioWidget';

  static List<TaskEntity> _cachedTasks = const [];
  static List<NoteEntity> _cachedNotes = const [];

  static Future<void> initialize() async {
    await HomeWidget.setAppGroupId(_appGroupId);
  }

  static Future<void> syncTasks(List<TaskEntity> tasks) async {
    _cachedTasks = tasks;
    await _publish();
  }

  static Future<void> syncNotes(List<NoteEntity> notes) async {
    _cachedNotes = notes;
    await _publish();
  }

  /// @deprecated Use [syncTasks] instead.
  static Future<void> updateTodayTasks(List<TaskEntity> tasks) =>
      syncTasks(tasks);

  static Future<void> _publish() async {
    final now = DateTime.now();
    final weekDays = _buildWeekStrip(now, _cachedTasks, _cachedNotes);
    final todayTasks = _todayTasks(now, _cachedTasks);
    final recentNotes = _recentNotes(now, _cachedNotes);

    await HomeWidget.saveWidgetData<String>(
      'month_label',
      DateFormat('MMMM yyyy').format(now),
    );
    await HomeWidget.saveWidgetData<String>('week_days', jsonEncode(weekDays));
    await HomeWidget.saveWidgetData<String>('tasks', jsonEncode(todayTasks));
    await HomeWidget.saveWidgetData<String>('notes', jsonEncode(recentNotes));
    await HomeWidget.saveWidgetData<String>(
      'widget_title',
      DateFormat('EEEE, MMM d').format(now),
    );

    await HomeWidget.updateWidget(
      name: _androidWidgetName,
      androidName: _androidWidgetName,
      iOSName: _iOSWidgetName,
    );
  }

  static List<Map<String, dynamic>> _buildWeekStrip(
    DateTime anchor,
    List<TaskEntity> tasks,
    List<NoteEntity> notes,
  ) {
    final monday = anchor.subtract(Duration(days: anchor.weekday - 1));

    return List.generate(7, (index) {
      final day = DateTime(monday.year, monday.month, monday.day + index);
      final taskCount = tasks
          .where((task) => _isSameDay(task.date, day) && !task.isDone)
          .length;
      final noteCount = notes
          .where(
            (note) =>
                _isSameDay(note.lastEditDate, day) ||
                _isSameDay(note.creationDate, day),
          )
          .length;

      return {
        'dow': DateFormat('E').format(day).substring(0, 1).toUpperCase(),
        'day': day.day,
        'today': _isSameDay(day, anchor),
        'tasks': taskCount,
        'notes': noteCount,
      };
    });
  }

  static List<Map<String, String>> _todayTasks(
    DateTime now,
    List<TaskEntity> tasks,
  ) {
    return tasks
        .where((task) => _isSameDay(task.date, now) && !task.isDone)
        .take(2)
        .map(
          (task) => {
            'title': task.title,
            'time': DateFormat('h:mm a').format(task.date),
          },
        )
        .toList();
  }

  static List<Map<String, String>> _recentNotes(
    DateTime now,
    List<NoteEntity> notes,
  ) {
    final sorted = List<NoteEntity>.from(notes)
      ..sort((a, b) => b.lastEditDate.compareTo(a.lastEditDate));

    final today = sorted
        .where(
          (note) =>
              _isSameDay(note.lastEditDate, now) ||
              _isSameDay(note.creationDate, now),
        )
        .take(2)
        .toList();

    final picked = today.isNotEmpty ? today : sorted.take(2).toList();

    return picked
        .map(
          (note) => {
            'title': note.title.isNotEmpty ? note.title : 'Untitled note',
            'time': DateFormat('MMM d').format(note.lastEditDate),
          },
        )
        .toList();
  }

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static Future<void> clearWidget() async {
    _cachedTasks = const [];
    _cachedNotes = const [];
    await HomeWidget.saveWidgetData<String>('week_days', '[]');
    await HomeWidget.saveWidgetData<String>('tasks', '[]');
    await HomeWidget.saveWidgetData<String>('notes', '[]');
    await HomeWidget.saveWidgetData<String>('month_label', '');
    await _publish();
  }

  static Future<void> registerBackgroundCallback() async {
    await HomeWidget.registerInteractivityCallback(backgroundCallback);
  }

  @pragma('vm:entry-point')
  static Future<void> backgroundCallback(Uri? uri) async {
    if (uri?.host == 'refresh') {
      await _publish();
    }
  }
}
