import 'dart:convert';
import 'package:home_widget/home_widget.dart';
import 'package:voclio_app/features/tasks/domain/entities/task_entity.dart';
import 'package:intl/intl.dart';

/// Service for managing the native home screen widget
class HomeScreenWidgetService {
  static const String _appGroupId = 'group.com.example.voclio_app';
  static const String _androidWidgetName = 'VoclioWidgetProvider';
  static const String _iOSWidgetName = 'VoclioWidget';

  /// Initialize the home widget
  static Future<void> initialize() async {
    await HomeWidget.setAppGroupId(_appGroupId);
  }

  /// Update the widget with today's tasks
  static Future<void> updateTodayTasks(List<TaskEntity> allTasks) async {
    final now = DateTime.now();
    
    // Filter tasks for today that are not done
    final todayTasks = allTasks.where((task) {
      return task.date.year == now.year &&
             task.date.month == now.month &&
             task.date.day == now.day &&
             !task.isDone;
    }).take(3).toList();

    // Convert to JSON format for the widget
    final tasksJson = todayTasks.map((task) {
      return {
        'title': task.title,
        'time': DateFormat('h:mm a').format(task.date),
        'priority': task.priority.toString().split('.').last,
      };
    }).toList();

    await HomeWidget.saveWidgetData<String>('tasks', jsonEncode(tasksJson));
    await HomeWidget.saveWidgetData<String>('widget_title', "Today's Tasks");
    
    await _updateWidget();
  }

  /// Update the widget with upcoming tasks
  static Future<void> updateUpcomingTasks(List<TaskEntity> allTasks) async {
    final now = DateTime.now();
    final weekFromNow = now.add(const Duration(days: 7));
    
    // Filter upcoming tasks
    final upcomingTasks = allTasks.where((task) {
      return task.date.isAfter(now) &&
             task.date.isBefore(weekFromNow) &&
             !task.isDone;
    }).take(3).toList();

    // Convert to JSON format for the widget
    final tasksJson = upcomingTasks.map((task) {
      return {
        'title': task.title,
        'time': DateFormat('EEE, MMM d').format(task.date),
        'priority': task.priority.toString().split('.').last,
      };
    }).toList();

    await HomeWidget.saveWidgetData<String>('tasks', jsonEncode(tasksJson));
    await HomeWidget.saveWidgetData<String>('widget_title', 'Upcoming Tasks');
    
    await _updateWidget();
  }

  /// Update widget with custom data
  static Future<void> updateCustomData({
    required String title,
    required List<Map<String, String>> items,
  }) async {
    await HomeWidget.saveWidgetData<String>('tasks', jsonEncode(items));
    await HomeWidget.saveWidgetData<String>('widget_title', title);
    
    await _updateWidget();
  }

  /// Trigger widget update
  static Future<void> _updateWidget() async {
    await HomeWidget.updateWidget(
      name: _androidWidgetName,
      androidName: _androidWidgetName,
      iOSName: _iOSWidgetName,
    );
  }

  /// Clear widget data
  static Future<void> clearWidget() async {
    await HomeWidget.saveWidgetData<String>('tasks', '[]');
    await HomeWidget.saveWidgetData<String>('widget_title', "Today's Tasks");
    await _updateWidget();
  }

  /// Register background callback for widget updates
  static Future<void> registerBackgroundCallback() async {
    await HomeWidget.registerInteractivityCallback(backgroundCallback);
  }

  /// Background callback handler
  @pragma('vm:entry-point')
  static Future<void> backgroundCallback(Uri? uri) async {
    if (uri != null) {
      if (uri.host == 'refresh') {
        // Handle refresh action from widget
        await _updateWidget();
      }
    }
  }
}
