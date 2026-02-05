import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/widget_preference.dart';

/// Service for managing widget preferences storage
class WidgetConfigService {
  static const String _preferencesKey = 'widget_preferences';
  static const String _setupShownKey = 'widget_setup_shown';

  final SharedPreferences _prefs;

  WidgetConfigService(this._prefs);

  /// Check if widget setup popup has been shown to the user
  bool get hasShownSetup => _prefs.getBool(_setupShownKey) ?? false;

  /// Mark that widget setup has been shown
  Future<bool> markSetupShown() async {
    return await _prefs.setBool(_setupShownKey, true);
  }

  /// Load widget preferences from storage
  WidgetPreferences loadPreferences() {
    final String? jsonString = _prefs.getString(_preferencesKey);
    if (jsonString == null) {
      return WidgetPreferences.defaultConfig();
    }
    try {
      final Map<String, dynamic> json = jsonDecode(jsonString);
      return WidgetPreferences.fromJson(json);
    } catch (e) {
      return WidgetPreferences.defaultConfig();
    }
  }

  /// Save widget preferences to storage
  Future<bool> savePreferences(WidgetPreferences preferences) async {
    try {
      final updatedPreferences = preferences.copyWith(
        lastUpdated: DateTime.now(),
      );
      final String jsonString = jsonEncode(updatedPreferences.toJson());
      return await _prefs.setString(_preferencesKey, jsonString);
    } catch (e) {
      return false;
    }
  }

  /// Update a single widget configuration
  Future<bool> updateWidget(WidgetType type, {bool? isEnabled, int? order}) async {
    final preferences = loadPreferences();
    final updatedWidgets = preferences.widgets.map((widget) {
      if (widget.type == type) {
        return widget.copyWith(
          isEnabled: isEnabled ?? widget.isEnabled,
          order: order ?? widget.order,
        );
      }
      return widget;
    }).toList();

    return savePreferences(preferences.copyWith(widgets: updatedWidgets));
  }

  /// Toggle widget enabled state
  Future<bool> toggleWidget(WidgetType type) async {
    final preferences = loadPreferences();
    final widget = preferences.widgets.firstWhere((w) => w.type == type);
    return updateWidget(type, isEnabled: !widget.isEnabled);
  }

  /// Reorder widgets
  Future<bool> reorderWidgets(List<WidgetType> newOrder) async {
    final preferences = loadPreferences();
    final updatedWidgets = preferences.widgets.map((widget) {
      final newIndex = newOrder.indexOf(widget.type);
      return widget.copyWith(order: newIndex >= 0 ? newIndex : widget.order);
    }).toList();

    return savePreferences(preferences.copyWith(widgets: updatedWidgets));
  }

  /// Mark setup as complete
  Future<bool> completeSetup() async {
    final preferences = loadPreferences();
    final success = await savePreferences(
      preferences.copyWith(hasCompletedSetup: true),
    );
    if (success) {
      await markSetupShown();
    }
    return success;
  }

  /// Reset to default preferences
  Future<bool> resetToDefaults() async {
    return savePreferences(WidgetPreferences.defaultConfig());
  }

  /// Clear all widget preferences
  Future<bool> clearPreferences() async {
    await _prefs.remove(_setupShownKey);
    return await _prefs.remove(_preferencesKey);
  }
}
