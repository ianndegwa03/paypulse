import 'package:flutter/services.dart';

/// Provides haptic feedback based on transaction amount
class HapticService {
  /// Light vibration for small transactions (<$20)
  static void light() {
    HapticFeedback.lightImpact();
  }

  /// Medium vibration for moderate transactions ($20-$100)
  static void medium() {
    HapticFeedback.mediumImpact();
  }

  /// Heavy vibration for large transactions (>$100)
  static void heavy() {
    HapticFeedback.heavyImpact();
  }

  /// Select appropriate haptic based on amount
  static void forAmount(double amount) {
    if (amount < 20) {
      light();
    } else if (amount < 100) {
      medium();
    } else {
      heavy();
    }
  }

  /// Success pattern - double tap
  static void success() {
    HapticFeedback.lightImpact();
    Future.delayed(const Duration(milliseconds: 100), () {
      HapticFeedback.lightImpact();
    });
  }

  /// Error pattern - heavy single
  static void error() {
    HapticFeedback.heavyImpact();
  }

  /// Selection click
  static void selectionClick() {
    HapticFeedback.selectionClick();
  }
}
