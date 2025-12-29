import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:paypulse/app/features/privacy/presentation/state/privacy_provider.dart';
import 'package:paypulse/app/features/wallet/presentation/state/currency_provider.dart';
import 'package:paypulse/app/features/auth/presentation/state/auth_notifier.dart';

class PayPulseCard extends ConsumerStatefulWidget {
  final double balance;
  final String cardHolderName;
  final String cardNumber;
  final String expiryDate;
  final bool isFrozen;
  final Color? cardColor;

  const PayPulseCard({
    super.key,
    required this.balance,
    required this.cardHolderName,
    required this.cardNumber,
    required this.expiryDate,
    this.isFrozen = false,
    this.cardColor,
  });

  @override
  ConsumerState<PayPulseCard> createState() => _PayPulseCardState();
}

class _PayPulseCardState extends ConsumerState<PayPulseCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _animation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutBack,
    ));
  }

  void _flipCard() {
    HapticFeedback.lightImpact();
    if (_isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    _isFront = !_isFront;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flipCard,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final angle = _animation.value * pi;
          final transform = Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle);

          return Transform(
            transform: transform,
            alignment: Alignment.center,
            child: angle < pi / 2
                ? _buildFront(context)
                : Transform(
                    transform: Matrix4.identity()..rotateY(pi),
                    alignment: Alignment.center,
                    child: _buildBack(context),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildFront(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.watch(authNotifierProvider).currentUser;
    final isPremium = user?.isPremiumUser ?? false;

    final color = widget.cardColor ??
        (isPremium ? const Color(0xFF1E1E1E) : theme.primaryColor);
    final isHidden = ref.watch(privacyProvider).isBalanceHidden;

    return Container(
      width: double.infinity,
      height: 235, // Increased from 220 to prevent overflow
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: widget.isFrozen
              ? [Colors.grey.shade400, Colors.grey.shade600]
              : isPremium
                  ? [const Color(0xFF1E1E1E), const Color(0xFF000000)]
                  : [color, color.withOpacity(0.85)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: (widget.isFrozen ? Colors.grey : color).withOpacity(0.3),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            // Abstract Premium Pattern
            if (isPremium)
              Positioned(
                right: -20,
                bottom: -20,
                child: Opacity(
                  opacity: 0.1,
                  child: Icon(Icons.star_outline_rounded,
                      size: 200, color: Colors.amber.shade200),
                ),
              ),

            // Glassmorphism Overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.05),
                      Colors.transparent,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Available Balance',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              ref
                                  .read(privacyProvider.notifier)
                                  .toggleBalanceVisibility();
                            },
                            child: Row(
                              children: [
                                Text(
                                  isHidden
                                      ? '••••••'
                                      : ref
                                          .watch(currencyProvider.notifier)
                                          .formatAmount(widget.balance),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 26,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                if (isPremium) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.shade300,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text("PRO",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 8)),
                                  ),
                                ]
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Text(
                        'PAYPULSE',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      _buildChip(),
                      const SizedBox(width: 16),
                      Icon(Icons.nfc_rounded,
                          color: Colors.white.withOpacity(0.4), size: 20),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.cardNumber.isNotEmpty
                        ? '••••   ••••   ••••   ${widget.cardNumber}'
                        : '••••   ••••   ••••   0000',
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'monospace',
                      fontSize: 18,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('CARD HOLDER',
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1)),
                          const SizedBox(height: 2),
                          Text(
                            widget.cardHolderName.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('EXPIRES',
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1)),
                          const SizedBox(height: 2),
                          Text(
                            widget.expiryDate,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip() {
    return Container(
      width: 40,
      height: 30,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber.shade200, Colors.amber.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2))
        ],
      ),
      child: Stack(
        children: List.generate(
            3,
            (i) => Positioned(
                  left: (i * 10).toDouble() + 5,
                  top: 5,
                  bottom: 5,
                  child: Container(width: 1, color: Colors.black12),
                )),
      ),
    );
  }

  Widget _buildBack(BuildContext context) {
    final user = ref.watch(authNotifierProvider).currentUser;
    final isPremium = user?.isPremiumUser ?? false;

    return Container(
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: const Color(0xFF121212),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 24),
          Container(height: 48, color: Colors.black),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 35,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4)),
                  alignment: Alignment.center,
                  child: const Text('123',
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2)),
                ),
                const SizedBox(width: 12),
                Text('SECURE CVV',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 10,
                        fontWeight: FontWeight.bold)),
                const Spacer(),
                const Icon(Icons.contactless_rounded,
                    color: Colors.white24, size: 28),
              ],
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(28)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _backAction(Icons.lock_outline_rounded, "Freeze", Colors.blue,
                    false, null),
                _backAction(Icons.analytics_outlined, "Insights", Colors.amber,
                    !isPremium, null),
                _backAction(Icons.add_moderator_outlined, "Limits",
                    Colors.green, !isPremium, null),
                _backAction(Icons.auto_awesome_outlined, "Virtual",
                    Colors.purple, !isPremium, () {
                  GoRouter.of(context).push('/create-ghost-card');
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _backAction(IconData icon, String label, Color color, bool isLocked,
      VoidCallback? onTap) {
    return GestureDetector(
      onTap: isLocked ? null : onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Icon(icon, color: isLocked ? Colors.grey : color, size: 20),
              if (isLocked)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Icon(Icons.lock_rounded,
                      size: 10, color: Colors.amber.shade300),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  color: isLocked ? Colors.grey : Colors.white70,
                  fontSize: 9,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
