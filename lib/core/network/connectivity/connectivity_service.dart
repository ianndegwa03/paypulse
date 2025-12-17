import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:paypulse/core/logging/logger_service.dart';

/// Service for managing network connectivity state
class ConnectivityService {
  ConnectivityService._();
  static final ConnectivityService instance = ConnectivityService._();

  final Connectivity _connectivity = Connectivity();
  List<ConnectivityResult> _currentStatus = [];
  bool _isInitialized = false;

  /// Initialize the connectivity service
  Future<void> initialize() async {
    _currentStatus = await _connectivity.checkConnectivity();
    _isInitialized = true;

    // Listen to connectivity changes
    _connectivity.onConnectivityChanged.listen((results) {
      _currentStatus = results;
      LoggerService.instance.d(
        'Connectivity changed: ${results.map((r) => r.name).join(", ")}',
        tag: 'Network',
      );
    });

    LoggerService.instance.d('ConnectivityService initialized', tag: 'Network');
  }

  /// Check if currently connected
  bool get isConnected => !_currentStatus.contains(ConnectivityResult.none);

  /// Check if connected via WiFi
  bool get isOnWifi => _currentStatus.contains(ConnectivityResult.wifi);

  /// Check if connected via mobile data
  bool get isOnMobile => _currentStatus.contains(ConnectivityResult.mobile);

  /// Get current connectivity status
  List<ConnectivityResult> get currentStatus =>
      List.unmodifiable(_currentStatus);

  /// Check if service is initialized
  bool get isInitialized => _isInitialized;

  /// Stream of connectivity changes
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged;

  /// Manually check connectivity
  Future<bool> checkConnectivity() async {
    _currentStatus = await _connectivity.checkConnectivity();
    return isConnected;
  }
}
