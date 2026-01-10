import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'dart:math';

/// Global confetti overlay for celebrating milestones
class ConfettiOverlay extends StatefulWidget {
  final Widget child;

  const ConfettiOverlay({super.key, required this.child});

  /// Call this from anywhere to trigger confetti
  static void celebrate(BuildContext context) {
    final state = context.findAncestorStateOfType<_ConfettiOverlayState>();
    state?._celebrate();
  }

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay> {
  late ConfettiController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _celebrate() {
    _controller.play();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _controller,
            blastDirection: pi / 2, // Downward
            blastDirectionality: BlastDirectionality.explosive,
            maxBlastForce: 20,
            minBlastForce: 8,
            emissionFrequency: 0.05,
            numberOfParticles: 30,
            gravity: 0.2,
            shouldLoop: false,
            colors: const [
              Color(0xFF6C5CE7),
              Color(0xFF00D9FF),
              Color(0xFFFFD93D),
              Color(0xFFFF6B6B),
              Color(0xFF6BCB77),
            ],
          ),
        ),
      ],
    );
  }
}
