import 'dart:ui';
import 'package:flutter/material.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      heightFactor: 1.0,
      child: Container(
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
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              height: 75,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E1E24).withOpacity(0.85)
                    : Colors.white.withOpacity(0.85),
                borderRadius: BorderRadius.circular(35),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _NavBarItem(
                    icon: Icons.home_rounded,
                    label: 'Home',
                    index: 0,
                    isSelected: selectedIndex == 0,
                    onTap: () => onItemSelected(0),
                  ),
                  _NavBarItem(
                    icon: Icons.explore_rounded,
                    label: 'Social',
                    index: 1,
                    isSelected: selectedIndex == 1,
                    onTap: () => onItemSelected(1),
                  ),
                  _NavBarItem(
                    icon: Icons.account_balance_wallet_rounded,
                    label: 'Wallet',
                    index: 2,
                    isSelected: selectedIndex == 2,
                    onTap: () => onItemSelected(2),
                  ),
                  _NavBarItem(
                    icon: Icons.bar_chart_rounded,
                    label: 'Insights',
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

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.fastOutSlowIn,
              padding: EdgeInsets.all(isSelected ? 12 : 8),
              decoration: BoxDecoration(
                color:
                    isSelected ? theme.colorScheme.primary : Colors.transparent,
                shape: BoxShape.circle,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: theme.colorScheme.primary.withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : [],
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey.withOpacity(0.7),
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
