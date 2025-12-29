import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class HolographicCard extends StatefulWidget {
  final Widget child;
  final bool enabled;

  const HolographicCard({
    super.key,
    required this.child,
    this.enabled = true,
  });

  @override
  State<HolographicCard> createState() => _HolographicCardState();
}

class _HolographicCardState extends State<HolographicCard> {
  double x = 0;
  double y = 0;

  @override
  void initState() {
    super.initState();
    if (widget.enabled) {
      gyroscopeEventStream().listen((GyroscopeEvent event) {
        if (!mounted) return;
        setState(() {
          // Accumulate rotation for a floaty feel, but clamp it to avoid spinning
          // Simple tilt based on current rotation rate isn't perfect for "position",
          // but good for subtle motion. For true "tilt", accelerometer is better,
          // but let's try a direct mapping of rotation first or a smoothed approach.

          // Actually, for a simple holographic effect, mapping accelerometer might be clearer.
          // Or just using gyroscope delta to slightly offset.
          // Let's us a simple dampening method.

          y += event.y;
          x += event.x;

          // Clamp to avoid extreme angles
          x = x.clamp(-0.2, 0.2);
          y = y.clamp(-0.2, 0.2);
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001) // Perspective
        ..rotateX(x)
        ..rotateY(y),
      alignment: Alignment.center,
      child: Stack(
        children: [
          widget.child,
          // Shimmer Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20), // Match card radius
                gradient: LinearGradient(
                  begin: Alignment(
                      x * -5, y * -5), // Move gradient opposite to tilt
                  end: Alignment(x * 5, y * 5),
                  colors: [
                    Colors.white.withOpacity(0.0),
                    Colors.white.withOpacity(0.1 +
                        (x.abs() + y.abs()) *
                            0.2), // Opacity based on tilt intensity
                    Colors.white.withOpacity(0.0),
                  ],
                  stops: const [0.3, 0.5, 0.7],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
