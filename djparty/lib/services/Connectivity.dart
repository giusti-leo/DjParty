import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  ConnectivityService() {
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      connectionController.add(_getStatus(result));
    });
  }

  StreamController<ConnectivityStatus> connectionController =
      StreamController<ConnectivityStatus>();

  ConnectivityStatus _getStatus(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.wifi:
        return ConnectivityStatus.Online;
      case ConnectivityResult.mobile:
        return ConnectivityStatus.Online;
      case ConnectivityResult.none:
        return ConnectivityStatus.Offline;
      default:
        return ConnectivityStatus.Online;
    }
  }
}

enum ConnectivityStatus { Online, Offline }
