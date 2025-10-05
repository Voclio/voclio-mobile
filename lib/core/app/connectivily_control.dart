import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';

class ConnectivityControler {
  ConnectivityControler._();

  static final ConnectivityControler instance = ConnectivityControler._();

  ValueNotifier<bool> isConected = ValueNotifier(true);

  void updateConnectionStatus(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.none)) {
      isConected.value = false;
    } else {
      isConected.value = true;
    }
  }

  Future<void> init() async {
    final results = await Connectivity().checkConnectivity();
    updateConnectionStatus(results);

    Connectivity().onConnectivityChanged.listen(updateConnectionStatus);
  }


}
