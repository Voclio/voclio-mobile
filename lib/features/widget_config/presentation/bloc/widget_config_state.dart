import 'package:equatable/equatable.dart';
import '../../domain/entities/widget_preference.dart';

enum WidgetConfigStatus { initial, loading, loaded, saving, saved, error }

class WidgetConfigState extends Equatable {
  final WidgetConfigStatus status;
  final WidgetPreferences preferences;
  final bool shouldShowSetup;
  final String? errorMessage;

  const WidgetConfigState({
    this.status = WidgetConfigStatus.initial,
    required this.preferences,
    this.shouldShowSetup = false,
    this.errorMessage,
  });

  factory WidgetConfigState.initial() {
    return WidgetConfigState(
      preferences: WidgetPreferences.defaultConfig(),
    );
  }

  WidgetConfigState copyWith({
    WidgetConfigStatus? status,
    WidgetPreferences? preferences,
    bool? shouldShowSetup,
    String? errorMessage,
  }) {
    return WidgetConfigState(
      status: status ?? this.status,
      preferences: preferences ?? this.preferences,
      shouldShowSetup: shouldShowSetup ?? this.shouldShowSetup,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// Get enabled widgets sorted by order
  List<WidgetConfig> get enabledWidgets => preferences.enabledWidgets;

  /// Check if a specific widget type is enabled
  bool isWidgetEnabled(WidgetType type) {
    final widget = preferences.widgets.firstWhere(
      (w) => w.type == type,
      orElse: () => WidgetConfig(type: type, isEnabled: false),
    );
    return widget.isEnabled;
  }

  @override
  List<Object?> get props => [status, preferences, shouldShowSetup, errorMessage];
}
