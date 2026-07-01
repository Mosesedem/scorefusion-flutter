import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class ConnectivityService {
  ConnectivityService({
    Connectivity? connectivity,
    InternetConnection? internetConnection,
  })  : _connectivity = connectivity ?? Connectivity(),
        _internetConnection = internetConnection ?? InternetConnection();

  final Connectivity _connectivity;
  final InternetConnection _internetConnection;

  Future<bool> hasConnection() async {
    try {
      final results = await _connectivity.checkConnectivity();
      final hasNetwork = results.any((r) => r != ConnectivityResult.none);
      if (!hasNetwork) return false;
      return _internetConnection.hasInternetAccess;
    } catch (_) {
      return false;
    }
  }

  Stream<bool> onConnectivityChanged() async* {
    await for (final results in _connectivity.onConnectivityChanged) {
      final hasNetwork = results.any((r) => r != ConnectivityResult.none);
      if (!hasNetwork) {
        yield false;
        continue;
      }
      yield await _internetConnection.hasInternetAccess;
    }
  }
}