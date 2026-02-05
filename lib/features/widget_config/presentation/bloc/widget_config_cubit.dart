import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/services/widget_config_service.dart';
import '../../domain/entities/widget_preference.dart';
import 'widget_config_state.dart';

class WidgetConfigCubit extends Cubit<WidgetConfigState> {
  final WidgetConfigService _service;

  WidgetConfigCubit(this._service) : super(WidgetConfigState.initial());

  /// Initialize and load preferences
  Future<void> init() async {
    emit(state.copyWith(status: WidgetConfigStatus.loading));
    
    try {
      final preferences = _service.loadPreferences();
      final hasShownSetup = _service.hasShownSetup;
      
      emit(state.copyWith(
        status: WidgetConfigStatus.loaded,
        preferences: preferences,
        shouldShowSetup: !hasShownSetup && !preferences.hasCompletedSetup,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: WidgetConfigStatus.error,
        errorMessage: 'Failed to load preferences: $e',
      ));
    }
  }

  /// Check if setup should be shown (for use after login/register)
  bool shouldShowSetupDialog() {
    return !_service.hasShownSetup;
  }

  /// Toggle a widget's enabled state
  Future<void> toggleWidget(WidgetType type) async {
    final currentWidget = state.preferences.widgets.firstWhere(
      (w) => w.type == type,
    );
    
    final updatedWidgets = state.preferences.widgets.map((widget) {
      if (widget.type == type) {
        return widget.copyWith(isEnabled: !currentWidget.isEnabled);
      }
      return widget;
    }).toList();

    emit(state.copyWith(
      preferences: state.preferences.copyWith(widgets: updatedWidgets),
    ));
  }

  /// Update multiple widget selections at once
  void updateWidgetSelections(Map<WidgetType, bool> selections) {
    final updatedWidgets = state.preferences.widgets.map((widget) {
      final isEnabled = selections[widget.type] ?? widget.isEnabled;
      return widget.copyWith(isEnabled: isEnabled);
    }).toList();

    emit(state.copyWith(
      preferences: state.preferences.copyWith(widgets: updatedWidgets),
    ));
  }

  /// Reorder widgets
  void reorderWidgets(int oldIndex, int newIndex) {
    final widgets = List<WidgetConfig>.from(state.preferences.widgets);
    
    // Get enabled widgets for reordering
    final enabledWidgets = widgets.where((w) => w.isEnabled).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
    
    if (oldIndex < enabledWidgets.length && newIndex <= enabledWidgets.length) {
      final widget = enabledWidgets.removeAt(oldIndex);
      enabledWidgets.insert(newIndex > oldIndex ? newIndex - 1 : newIndex, widget);
      
      // Update order for all enabled widgets
      for (int i = 0; i < enabledWidgets.length; i++) {
        final index = widgets.indexWhere((w) => w.type == enabledWidgets[i].type);
        if (index >= 0) {
          widgets[index] = widgets[index].copyWith(order: i);
        }
      }
      
      emit(state.copyWith(
        preferences: state.preferences.copyWith(widgets: widgets),
      ));
    }
  }

  /// Save current preferences
  Future<bool> savePreferences() async {
    emit(state.copyWith(status: WidgetConfigStatus.saving));
    
    try {
      final success = await _service.savePreferences(state.preferences);
      if (success) {
        emit(state.copyWith(
          status: WidgetConfigStatus.saved,
          preferences: state.preferences.copyWith(hasCompletedSetup: true),
        ));
        return true;
      } else {
        emit(state.copyWith(
          status: WidgetConfigStatus.error,
          errorMessage: 'Failed to save preferences',
        ));
        return false;
      }
    } catch (e) {
      emit(state.copyWith(
        status: WidgetConfigStatus.error,
        errorMessage: 'Error saving preferences: $e',
      ));
      return false;
    }
  }

  /// Complete the setup process
  Future<bool> completeSetup() async {
    try {
      final prefsSuccess = await _service.savePreferences(
        state.preferences.copyWith(hasCompletedSetup: true),
      );
      final setupSuccess = await _service.markSetupShown();
      
      if (prefsSuccess && setupSuccess) {
        emit(state.copyWith(
          status: WidgetConfigStatus.saved,
          shouldShowSetup: false,
          preferences: state.preferences.copyWith(hasCompletedSetup: true),
        ));
        return true;
      }
      return false;
    } catch (e) {
      emit(state.copyWith(
        status: WidgetConfigStatus.error,
        errorMessage: 'Error completing setup: $e',
      ));
      return false;
    }
  }

  /// Skip setup (mark as shown but don't complete)
  Future<void> skipSetup() async {
    await _service.markSetupShown();
    emit(state.copyWith(shouldShowSetup: false));
  }

  /// Reset to default preferences
  Future<void> resetToDefaults() async {
    emit(state.copyWith(status: WidgetConfigStatus.loading));
    
    try {
      await _service.resetToDefaults();
      emit(state.copyWith(
        status: WidgetConfigStatus.loaded,
        preferences: WidgetPreferences.defaultConfig(),
      ));
    } catch (e) {
      emit(state.copyWith(
        status: WidgetConfigStatus.error,
        errorMessage: 'Failed to reset preferences: $e',
      ));
    }
  }
}
