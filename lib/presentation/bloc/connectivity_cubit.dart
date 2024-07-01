import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum ConnectivityStatus { connected, disconnected, unknown }


class ConnectivityCubit extends Cubit<bool>{

  final Connectivity _connectivity = Connectivity();


  ConnectivityCubit() : super(false) {
    _checkConnectivity();
    _connectivity.onConnectivityChanged.listen((result) {
      _updateConnectivity(result);
    });
  }

  Future<void> _checkConnectivity() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    _updateConnectivity(connectivityResult);
  }

  void _updateConnectivity(List<ConnectivityResult> connectivityResult) {
    if (connectivityResult.contains(ConnectivityResult.mobile) ||
        connectivityResult.contains(ConnectivityResult.wifi)) {
      emit(true);
    } else {
      emit(false);
    }
  }

  void refreshConnectivity() => _checkConnectivity();
}