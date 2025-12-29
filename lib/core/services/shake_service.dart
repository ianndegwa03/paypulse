import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

/// Service that detects shake gestures and triggers callbacks
class ShakeService {
  static const double _shakeThreshold = 15.0;
  static const Duration _shakeCooldown = Duration(milliseconds: 1000);

  StreamSubscription<AccelerometerEvent>? _subscription;
  DateTime _lastShakeTime = DateTime.now();
  VoidCallback? _onShake;

  void startListening(VoidCallback onShake) {
    _onShake = onShake;
    _subscription =
        accelerometerEventStream().listen(_handleAccelerometerEvent);
  }

  void _handleAccelerometerEvent(AccelerometerEvent event) {
    final double acceleration =
        (event.x.abs() + event.y.abs() + event.z.abs()) -
            9.8; // Subtract gravity

    if (acceleration > _shakeThreshold) {
      final now = DateTime.now();
      if (now.difference(_lastShakeTime) > _shakeCooldown) {
        _lastShakeTime = now;
        _onShake?.call();
      }
    }
  }

  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
  }

  void dispose() {
    stopListening();
  }
}
