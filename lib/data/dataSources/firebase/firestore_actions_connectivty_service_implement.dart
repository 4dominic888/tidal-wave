import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tidal_wave/data/abstractions/connectivity_service_base.dart';

class FirestoreActionsConnectityServiceImplement extends ConnectivityServiceBase {
  
  final db = FirebaseFirestore.instance;
  
  @override
  void onNetworkConnected() async {
    await db.enableNetwork();
  }

  @override
  void onNetworkDisconnected() async {
    await db.disableNetwork();
  }
  
}