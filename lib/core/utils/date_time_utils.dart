import 'package:intl/intl.dart';

/// Shared helpers for task due dates (local wall-clock time).
abstract final class DateTimeUtils {
  static DateTime toLocal(DateTime value) =>
      value.isUtc ? value.toLocal() : value;

  static DateTime parseApi(dynamic raw) {
    if (raw == null) return DateTime.now();
    final text = raw.toString().trim();
    if (text.isEmpty) return DateTime.now();

    final parsed = DateTime.parse(text);
    return parsed.isUtc ? parsed.toLocal() : parsed;
  }

  /// Send due dates to the API as UTC while preserving the user's local time.
  static String toApiIso(DateTime localDateTime) =>
      toLocal(localDateTime).toUtc().toIso8601String();

  static DateTime dateOnly(DateTime value) {
    final local = toLocal(value);
    return DateTime(local.year, local.month, local.day);
  }

  static bool isSameDay(DateTime a, DateTime b) =>
      dateOnly(a) == dateOnly(b);

  static bool isOverdue(DateTime dueDate, {required bool isCompleted}) {
    if (isCompleted) return false;
    return toLocal(dueDate).isBefore(DateTime.now());
  }

  static String formatTaskDue(DateTime dueDate) {
    final local = toLocal(dueDate);
    final now = DateTime.now();
    final today = dateOnly(now);
    final dueDay = dateOnly(local);
    final time = DateFormat.jm().format(local);

    if (dueDay == today) return 'Today, $time';
    if (dueDay == today.add(const Duration(days: 1))) {
      return 'Tomorrow, $time';
    }
    return DateFormat('MMM d, h:mm a').format(local);
  }

  static String formatCalendarDue(DateTime dueDate) =>
      DateFormat('MMM d, h:mm a').format(toLocal(dueDate));
}
