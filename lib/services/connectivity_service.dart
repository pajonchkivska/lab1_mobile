// lib/services/connectivity_service.dart

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

enum InternetStatus { connected, disconnected }

class ConnectivityService with ChangeNotifier {
  InternetStatus _status = InternetStatus.disconnected;

  InternetStatus get status => _status;
  bool get isConnected => _status == InternetStatus.connected;

  final Connectivity _connectivity = Connectivity();

  ConnectivityService() {
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    _checkInitialConnection();
  }

  Future<void> _checkInitialConnection() async {
    final result = await _connectivity.checkConnectivity();
    _updateConnectionStatus(result);
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    final previouslyConnected = isConnected;

    if (result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.ethernet) {
      _status = InternetStatus.connected;
    } else {
      _status = InternetStatus.disconnected;
    }

    if (previouslyConnected != isConnected) {
      notifyListeners();
    }
  }
}
