import 'package:flutter/material.dart';

/// A card widget that applies 3D parallax effect based on scroll position
class ParallaxCard extends StatelessWidget {
  final Widget child;
  final double scrollOffset;
  final double index;

  const ParallaxCard({
    super.key,
    required this.child,
    required this.scrollOffset,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate parallax offset based on card position
    final double cardOffset = index * 100 - scrollOffset;
    final double parallaxFactor = (cardOffset / 500).clamp(-0.1, 0.1);

    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001) // Perspective
        ..rotateX(parallaxFactor * 0.5)
        ..translate(0.0, parallaxFactor * 10),
      alignment: Alignment.center,
      child: child,
    );
  }
}

/// A scroll controller mixin that provides parallax offset
class ParallaxScrollController extends ScrollController {
  double get parallaxOffset => hasClients ? offset : 0.0;
}
