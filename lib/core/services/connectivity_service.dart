import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../utils/debug_print.dart';

class ConnectivityService extends GetxService {
  final RxBool isConnected = true.obs;

  StreamSubscription<List<ConnectivityResult>>? _subscription;

  @override
  void onInit() {
    super.onInit();
    _checkInitial();
    _subscription = Connectivity().onConnectivityChanged.listen((results) {
      isConnected.value = !results.contains(ConnectivityResult.none);
      dPrint('Connectivity changed: $results');
    });
  }

  Future<void> _checkInitial() async {
    final results = await Connectivity().checkConnectivity();
    isConnected.value = !results.contains(ConnectivityResult.none);
  }

  /// Verifies actual internet reachability, not just an active interface.
  Future<bool> hasInternet() => InternetConnectionChecker().hasConnection;

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}
