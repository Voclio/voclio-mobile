import 'package:equatable/equatable.dart';

/// Types of widgets the user can display on their home screen
enum WidgetType {
  upcomingTasks,
  todayTasks,
  calendar,
  notes,
  reminders,
  productivity,
  quickActions,
}

/// Extension to provide display names and icons for widget types
extension WidgetTypeExtension on WidgetType {
  String get displayName {
    switch (this) {
      case WidgetType.upcomingTasks:
        return 'Upcoming Tasks';
      case WidgetType.todayTasks:
        return 'Today\'s Tasks';
      case WidgetType.calendar:
        return 'Calendar Events';
      case WidgetType.notes:
        return 'Recent Notes';
      case WidgetType.reminders:
        return 'Reminders';
      case WidgetType.productivity:
        return 'Productivity Stats';
      case WidgetType.quickActions:
        return 'Quick Actions';
    }
  }

  String get description {
    switch (this) {
      case WidgetType.upcomingTasks:
        return 'See your upcoming tasks for the next 7 days';
      case WidgetType.todayTasks:
        return 'View and manage your tasks for today';
      case WidgetType.calendar:
        return 'View your calendar events at a glance';
      case WidgetType.notes:
        return 'Quick access to your recent notes';
      case WidgetType.reminders:
        return 'Stay on top of your reminders';
      case WidgetType.productivity:
        return 'Track your daily productivity';
      case WidgetType.quickActions:
        return 'Quick shortcuts to common actions';
    }
  }

  String get iconName {
    switch (this) {
      case WidgetType.upcomingTasks:
        return 'upcoming';
      case WidgetType.todayTasks:
        return 'today';
      case WidgetType.calendar:
        return 'calendar';
      case WidgetType.notes:
        return 'notes';
      case WidgetType.reminders:
        return 'reminders';
      case WidgetType.productivity:
        return 'productivity';
      case WidgetType.quickActions:
        return 'quick_actions';
    }
  }
}

/// Model for a single widget configuration
class WidgetConfig extends Equatable {
  final WidgetType type;
  final bool isEnabled;
  final int order;
  final Map<String, dynamic>? customSettings;

  const WidgetConfig({
    required this.type,
    this.isEnabled = true,
    this.order = 0,
    this.customSettings,
  });

  WidgetConfig copyWith({
    WidgetType? type,
    bool? isEnabled,
    int? order,
    Map<String, dynamic>? customSettings,
  }) {
    return WidgetConfig(
      type: type ?? this.type,
      isEnabled: isEnabled ?? this.isEnabled,
      order: order ?? this.order,
      customSettings: customSettings ?? this.customSettings,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.index,
      'isEnabled': isEnabled,
      'order': order,
      'customSettings': customSettings,
    };
  }

  factory WidgetConfig.fromJson(Map<String, dynamic> json) {
    return WidgetConfig(
      type: WidgetType.values[json['type'] as int],
      isEnabled: json['isEnabled'] as bool? ?? true,
      order: json['order'] as int? ?? 0,
      customSettings: json['customSettings'] as Map<String, dynamic>?,
    );
  }

  @override
  List<Object?> get props => [type, isEnabled, order, customSettings];
}

/// Model for all user widget preferences
class WidgetPreferences extends Equatable {
  final List<WidgetConfig> widgets;
  final bool hasCompletedSetup;
  final DateTime? lastUpdated;

  const WidgetPreferences({
    required this.widgets,
    this.hasCompletedSetup = false,
    this.lastUpdated,
  });

  /// Default widget configuration for new users
  factory WidgetPreferences.defaultConfig() {
    return WidgetPreferences(
      widgets: [
        const WidgetConfig(type: WidgetType.todayTasks, isEnabled: true, order: 0),
        const WidgetConfig(type: WidgetType.upcomingTasks, isEnabled: true, order: 1),
        const WidgetConfig(type: WidgetType.calendar, isEnabled: false, order: 2),
        const WidgetConfig(type: WidgetType.notes, isEnabled: false, order: 3),
        const WidgetConfig(type: WidgetType.reminders, isEnabled: false, order: 4),
        const WidgetConfig(type: WidgetType.productivity, isEnabled: false, order: 5),
        const WidgetConfig(type: WidgetType.quickActions, isEnabled: false, order: 6),
      ],
      hasCompletedSetup: false,
    );
  }

  WidgetPreferences copyWith({
    List<WidgetConfig>? widgets,
    bool? hasCompletedSetup,
    DateTime? lastUpdated,
  }) {
    return WidgetPreferences(
      widgets: widgets ?? this.widgets,
      hasCompletedSetup: hasCompletedSetup ?? this.hasCompletedSetup,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// Get only enabled widgets sorted by order
  List<WidgetConfig> get enabledWidgets {
    return widgets.where((w) => w.isEnabled).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  Map<String, dynamic> toJson() {
    return {
      'widgets': widgets.map((w) => w.toJson()).toList(),
      'hasCompletedSetup': hasCompletedSetup,
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }

  factory WidgetPreferences.fromJson(Map<String, dynamic> json) {
    return WidgetPreferences(
      widgets: (json['widgets'] as List<dynamic>)
          .map((w) => WidgetConfig.fromJson(w as Map<String, dynamic>))
          .toList(),
      hasCompletedSetup: json['hasCompletedSetup'] as bool? ?? false,
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props => [widgets, hasCompletedSetup, lastUpdated];
}
