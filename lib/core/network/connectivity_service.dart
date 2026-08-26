import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';

/// Observes device network reachability (Android, iOS, Web).
class ConnectivityService {
  ConnectivityService({Connectivity? connectivity, Dio? dio})
      : _connectivity = connectivity ?? Connectivity(),
        _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 4),
                receiveTimeout: const Duration(seconds: 4),
                sendTimeout: const Duration(seconds: 4),
                // Any HTTP response means the network path works.
                validateStatus: (_) => true,
              ),
            );

  final Connectivity _connectivity;
  final Dio _dio;

  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged;

  /// True when the device can reach the public internet.
  ///
  /// Interface status alone is unreliable (esp. iOS Simulator), so Retry
  /// verifies with a short HTTP probe.
  Future<bool> get isConnected async {
    try {
      await _dio.head('https://one.one.one.one');
      return true;
    } catch (_) {
      try {
        final results = await _connectivity.checkConnectivity();
        return _hasConnection(results);
      } catch (_) {
        return false;
      }
    }
  }

  bool _hasConnection(List<ConnectivityResult> results) {
    if (results.isEmpty) return false;
    return results.any((r) => r != ConnectivityResult.none);
  }
}
