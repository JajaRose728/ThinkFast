import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  /// Check if device has internet connection
  Future<bool> hasInternet() async {
    try {
      final result = await _connectivity.checkConnectivity();
      return result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.ethernet;
    } catch (e) {
      print('Error checking connectivity: $e');
      return false;
    }
  }

  /// Listen to connectivity changes
  Stream<bool> get connectivityStream {
    return _connectivity.onConnectivityChanged.map((result) {
      return result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.ethernet;
    });
  }
}