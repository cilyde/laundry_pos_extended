// lib/services/connectivity_service.dart

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';

class ConnectivityService {
  static Future<bool> hasConnection() async {
    final result = await Connectivity().checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }
}

Future<bool> checkOnline() async {
  final isConnected = await ConnectivityService.hasConnection();
  if (!isConnected) {
    debugPrint('No internet connection.');
    return false;
  }
  return true;
}
