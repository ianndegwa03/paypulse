import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:paypulse/core/theme/design_system_v2.dart';

class FloatingNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const FloatingNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      heightFactor: 1.0,
      child: Container(
        height: 75,
        margin: const EdgeInsets.only(left: 20, right: 20, bottom: 30),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(35),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 40,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(35),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: isDark ? PulseDesign.glassDark : PulseDesign.glassLight,
                borderRadius: BorderRadius.circular(35),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.08)
                      : Colors.black.withOpacity(0.05),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _NavBarItem(
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home_rounded,
                    label: 'Home',
                    index: 0,
                    isSelected: selectedIndex == 0,
                    onTap: () => onItemSelected(0),
                  ),
                  _NavBarItem(
                    icon: Icons.account_balance_wallet_outlined,
                    activeIcon: Icons.account_balance_wallet_rounded,
                    label: 'Wallet',
                    index: 1,
                    isSelected: selectedIndex == 1,
                    onTap: () => onItemSelected(1),
                  ),

                  // The Pulse / Action Hub
                  _PulseHub(onTap: () => onItemSelected(4)),

                  _NavBarItem(
                    icon: Icons.auto_graph_outlined,
                    activeIcon: Icons.auto_graph_rounded,
                    label: 'Insights',
                    index: 2,
                    isSelected: selectedIndex == 2,
                    onTap: () => onItemSelected(2),
                  ),
                  _NavBarItem(
                    icon: Icons.alternate_email_rounded, // Threads-like icon
                    activeIcon: Icons.alternate_email_rounded,
                    label: 'Threads',
                    index: 3,
                    isSelected: selectedIndex == 3,
                    onTap: () => onItemSelected(3),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PulseHub extends StatelessWidget {
  final VoidCallback onTap;

  const _PulseHub({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int index;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.index,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.15 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(8),
                child: Icon(
                  isSelected ? activeIcon : icon,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : (isDark ? Colors.white54 : Colors.black45),
                  size: 26,
                ),
              ),
            ),
            if (isSelected)
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ).animate().scale(duration: 200.ms),
          ],
        ),
      ),
    );
  }
}
