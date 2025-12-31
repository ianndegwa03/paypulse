import 'package:flutter/material.dart';
import 'package:paypulse/domain/entities/virtual_card_entity.dart';

class Premium3DCard extends StatefulWidget {
  final VirtualCardEntity card;
  const Premium3DCard({super.key, required this.card});

  @override
  State<Premium3DCard> createState() => _Premium3DCardState();
}

class _Premium3DCardState extends State<Premium3DCard>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  double _dragX = 0.0;
  double _dragY = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _dragX += details.delta.dx * 0.01;
      _dragY -= details.delta.dy * 0.01; // Invert Y
      _dragX = _dragX.clamp(-0.5, 0.5);
      _dragY = _dragY.clamp(-0.5, 0.5);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    final startX = _dragX;
    final startY = _dragY;

    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    final animX = Tween<double>(begin: startX, end: 0).animate(
        CurvedAnimation(parent: _controller!, curve: Curves.elasticOut));
    final animY = Tween<double>(begin: startY, end: 0).animate(
        CurvedAnimation(parent: _controller!, curve: Curves.elasticOut));

    _controller?.addListener(() {
      setState(() {
        _dragX = animX.value;
        _dragY = animY.value;
      });
    });
    _controller?.forward();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: Transform(
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001) // Perspective
          ..rotateX(_dragY)
          ..rotateY(_dragX),
        alignment: Alignment.center,
        child: Container(
          height: 220,
          width: double.infinity,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: _getGradient(widget.card.design),
              boxShadow: [
                BoxShadow(
                  color: _getShadowColor(widget.card.design).withOpacity(0.4),
                  blurRadius: 20,
                  offset: Offset(_dragX * 20, _dragY * 20 + 20),
                )
              ]),
          child: Stack(
            children: [
              // Shine Effect
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      begin: Alignment(-_dragX * 5, -_dragY * 5),
                      end: Alignment(_dragX * 5, _dragY * 5),
                      colors: [
                        Colors.white.withOpacity(0.0),
                        Colors.white.withOpacity(0.2), // Simple Shine
                        Colors.white.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("PayPulse",
                            style: TextStyle(
                                fontFamily: 'Courier',
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: _getTextColor(widget.card.design))),
                        Text(widget.card.network.name.toUpperCase(),
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: _getTextColor(widget.card.design))),
                      ],
                    ),
                    Row(
                      children: [
                        _chipWidget(),
                        const SizedBox(width: 16),
                        Icon(Icons.wifi,
                            color: _getTextColor(widget.card.design)
                                .withOpacity(0.7)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("**** **** **** ${widget.card.last4}",
                            style: TextStyle(
                                fontFamily: 'Courier',
                                fontSize: 22,
                                letterSpacing: 2,
                                color: _getTextColor(widget.card.design))),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(widget.card.cardHolderName.toUpperCase(),
                                style: TextStyle(
                                    fontFamily: 'Courier',
                                    letterSpacing: 1,
                                    color: _getTextColor(widget.card.design))),
                            Text(widget.card.expiryDate,
                                style: TextStyle(
                                    fontFamily: 'Courier',
                                    color: _getTextColor(widget.card.design))),
                          ],
                        )
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _chipWidget() {
    return Container(
      width: 40,
      height: 30,
      decoration: BoxDecoration(
        color: const Color(0xFFD4AF37),
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }

  LinearGradient _getGradient(CardDesign design) {
    switch (design) {
      case CardDesign.metalBlack:
        return const LinearGradient(
            colors: [Color(0xFF2C3E50), Color(0xFF000000)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight);
      case CardDesign.cyberNeon:
        return const LinearGradient(
            colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight);
      case CardDesign.goldLuxury:
        return const LinearGradient(
            colors: [Color(0xFFFFD700), Color(0xFFB8860B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight);
      case CardDesign.glassFrost:
        return LinearGradient(colors: [
          Colors.white.withOpacity(0.3),
          Colors.white.withOpacity(0.1)
        ], begin: Alignment.topLeft, end: Alignment.bottomRight);
    }
  }

  Color _getShadowColor(CardDesign design) {
    switch (design) {
      case CardDesign.cyberNeon:
        return Colors.purpleAccent;
      case CardDesign.goldLuxury:
        return Colors.amber;
      default:
        return Colors.black;
    }
  }

  Color _getTextColor(CardDesign design) {
    if (design == CardDesign.glassFrost) return Colors.black87;
    return Colors.white.withOpacity(0.9);
  }
}
