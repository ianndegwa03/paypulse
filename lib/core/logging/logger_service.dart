import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// Logger service for centralized logging throughout the application.
/// Provides different log levels and optional file/crashlytics integration.
class LoggerService {
  LoggerService._();
  static final LoggerService instance = LoggerService._();

  bool _enableFileLogging = false;
  bool _enableCrashlytics = false;
  bool _isInitialized = false;

  /// Initialize the logger with optional configurations
  Future<void> initialize({
    bool enableFileLogging = false,
    bool enableCrashlytics = false,
  }) async {
    _enableFileLogging = enableFileLogging;
    _enableCrashlytics = enableCrashlytics;
    _isInitialized = true;
    d('LoggerService initialized');
  }

  /// Log info message
  void i(String message, {String? tag}) {
    _log('INFO', message, tag: tag);
  }

  /// Log debug message
  void d(String message, {String? tag}) {
    if (kDebugMode) {
      _log('DEBUG', message, tag: tag);
    }
  }

  /// Log warning message
  void w(String message, {String? tag, Object? error}) {
    _log('WARN', message, tag: tag, error: error);
  }

  /// Log error message
  void e(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log('ERROR', message, tag: tag, error: error, stackTrace: stackTrace);

    // Report to crashlytics if enabled
    if (_enableCrashlytics && error != null) {
      _reportToCrashlytics(error, stackTrace);
    }
  }

  void _log(
    String level,
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final timestamp = DateTime.now().toIso8601String();
    final tagPrefix = tag != null ? '[$tag] ' : '';
    final formattedMessage = '[$timestamp] [$level] $tagPrefix$message';

    if (kDebugMode) {
      developer.log(
        formattedMessage,
        name: 'PayPulse',
        error: error,
        stackTrace: stackTrace,
      );
    }

    // File logging placeholder
    if (_enableFileLogging) {
      _writeToFile(formattedMessage);
    }
  }

  void _writeToFile(String message) {
    // File logging implementation can be added here
    // For now, this is a placeholder
  }

  void _reportToCrashlytics(Object error, StackTrace? stackTrace) {
    // Crashlytics integration can be added here
    // Example: FirebaseCrashlytics.instance.recordError(error, stackTrace);
  }
}
