import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

class PulseActionHub extends StatelessWidget {
  const PulseActionHub({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.black.withOpacity(0.4)
              : Colors.white.withOpacity(0.4),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              "Action Hub",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              "Quick access to financial pulses",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionItem(
                  context,
                  icon: Icons.send_rounded,
                  label: "Send",
                  color: Colors.blue,
                  onTap: () {
                    context.pop();
                    context.push('/send-money');
                  },
                ),
                _buildActionItem(
                  context,
                  icon: Icons.south_west_rounded,
                  label: "Request",
                  color: Colors.green,
                  onTap: () {
                    context.pop();
                    context.push('/contacts');
                  },
                ),
                _buildActionItem(
                  context,
                  icon: Icons.qr_code_scanner_rounded,
                  label: "History",
                  color: Colors.purple,
                  onTap: () {
                    context.pop();
                    context.push('/transaction-history');
                  },
                ),
                _buildActionItem(
                  context,
                  icon: Icons.add_rounded,
                  label: "Contacts",
                  color: Colors.orange,
                  onTap: () {
                    context.pop();
                    context.push('/contacts');
                  },
                ),
              ],
            ),
            const SizedBox(height: 40),
            PrimaryButtonWrapper(
              label: "Cancel",
              onPressed: () => context.pop(),
              isOutline: true,
            ),
          ],
        ).animate().slideY(begin: 0.1, end: 0, curve: Curves.easeOutBack),
      ),
    );
  }

  Widget _buildActionItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ).animate().scale(delay: const Duration(milliseconds: 100)),
    );
  }
}

class PrimaryButtonWrapper extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isOutline;

  const PrimaryButtonWrapper({
    super.key,
    required this.label,
    required this.onPressed,
    this.isOutline = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isOutline) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            side: BorderSide(color: Colors.grey.withOpacity(0.2)),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: Text(label),
      ),
    );
  }
}
