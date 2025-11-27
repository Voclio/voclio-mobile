import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';

/// Connectivity controller for managing network connection status in Voclio app
/// Uses singleton pattern to ensure single instance across the app
/// Monitors network connectivity changes and notifies the app
class ConnectivityControler {
  ConnectivityControler._();

  /// Singleton instance of ConnectivityControler
  static final ConnectivityControler instance = ConnectivityControler._();

  /// Notifier for connectivity changes - true when connected, false when disconnected
  ValueNotifier<bool> isConected = ValueNotifier(true);

  /// Update connection status based on connectivity results
  /// [results] - list of connectivity results from the system
  void updateConnectionStatus(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.none)) {
      isConected.value = false;
    } else {
      isConected.value = true;
    }
  }

  /// Initialize connectivity monitoring
  /// Should be called during app startup
  /// Sets up listeners for connectivity changes
  Future<void> init() async {
    // Check initial connectivity status
    final results = await Connectivity().checkConnectivity();
    updateConnectionStatus(results);

    // Listen for connectivity changes
    Connectivity().onConnectivityChanged.listen(updateConnectionStatus);
  }
}
