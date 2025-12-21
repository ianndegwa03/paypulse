import 'package:flutter/widgets.dart';

/// Manages accessibility settings for the application
class AccessibilityService {
  AccessibilityService._();
  static final AccessibilityService instance = AccessibilityService._();

  double _textScaleFactor = 1.0;
  bool _isInitialized = false;

  /// Initialize the accessibility service
  void initialize() {
    _isInitialized = true;
  }

  /// Get a text scaler that respects accessibility settings
  TextScaler getTextScaler(TextScaler systemScaler) {
    try {
      // Apply any custom scaling on top of system settings if supported.
      if (_textScaleFactor != 1.0) {
        // Some Flutter versions expose TextScaler APIs; guard against
        // potential incompatibilities by returning the system scaler if
        // an operation fails.
        return TextScaler.linear(systemScaler.scale(_textScaleFactor));
      }
    } catch (_) {
      // Fall back to system scaler on any unexpected error.
      return systemScaler;
    }

    return systemScaler;
  }

  /// Set custom text scale factor
  void setTextScaleFactor(double factor) {
    _textScaleFactor = factor.clamp(0.5, 3.0);
  }

  /// Reset to system default
  void resetTextScale() {
    _textScaleFactor = 1.0;
  }

  /// Get current text scale factor
  double get textScaleFactor => _textScaleFactor;

  /// Check if service is initialized
  bool get isInitialized => _isInitialized;
}
