import 'package:paypulse/core/logging/logger_service.dart';

/// Observer for bloc/state management events
/// Since Riverpod is used (not Bloc), this provides a compatible interface
class AppBlocObserver {
  AppBlocObserver._();
  static final AppBlocObserver instance = AppBlocObserver._();

  bool _isInitialized = false;

  /// Initialize the observer
  void initialize() {
    _isInitialized = true;
    LoggerService.instance.d('AppBlocObserver initialized', tag: 'State');
  }

  /// Log state change
  void onStateChange(
      String providerName, Object? previousState, Object? newState) {
    if (_isInitialized) {
      LoggerService.instance.d(
        '$providerName: state changed',
        tag: 'State',
      );
    }
  }

  /// Log error
  void onError(String providerName, Object error, StackTrace stackTrace) {
    LoggerService.instance.e(
      '$providerName: error occurred',
      tag: 'State',
      error: error,
      stackTrace: stackTrace,
    );
  }

  bool get isInitialized => _isInitialized;
}
