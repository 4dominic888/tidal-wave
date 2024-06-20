import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

abstract class ConnectivityServiceBase{
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  void onNetworkConnected();
  void onNetworkDisconnected();

  void init(){
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((result) {
      if (result.contains(ConnectivityResult.none)) { onNetworkDisconnected(); }
      else { onNetworkConnected();}
    });
  }

  void dispose() {
    _connectivitySubscription.cancel();
  }
}