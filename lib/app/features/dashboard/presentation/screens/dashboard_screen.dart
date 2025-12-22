import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paypulse/app/features/dashboard/presentation/screens/home_tab_screen.dart';
import 'package:paypulse/app/features/dashboard/presentation/screens/insights_tab_screen.dart';
import 'package:paypulse/app/features/social/presentation/screens/social_tab_screen.dart';
import 'package:paypulse/app/features/wallet/presentation/screens/wallet_overview_screen.dart';
import 'package:paypulse/app/features/dashboard/presentation/screens/profile_tab_screen.dart';

final _dashboardTabIndexProvider = StateProvider<int>((ref) => 0);

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(_dashboardTabIndexProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final tabs = [
      const HomeTabScreen(),
      const SocialTabScreen(),
      const WalletOverviewScreen(),
      const InsightsTabScreen(),
      const ProfileTabScreen(),
    ];

    return Scaffold(
      extendBody: true, // This allows the body to go behind the bottom bar
      body: tabs[selectedIndex],
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(left: 20, right: 20, bottom: 24),
        height: 72,
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF1C1C1E).withOpacity(0.9)
              : Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(ref, 0, Icons.home_rounded, selectedIndex),
              _buildNavItem(ref, 1, Icons.explore_rounded, selectedIndex),
              _buildNavItem(
                  ref, 2, Icons.account_balance_wallet_rounded, selectedIndex),
              _buildNavItem(ref, 3, Icons.bar_chart_rounded, selectedIndex),
              _buildNavItem(ref, 4, Icons.person_rounded, selectedIndex),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
      WidgetRef ref, int index, IconData icon, int selectedIndex) {
    final isSelected = selectedIndex == index;
    final theme = Theme.of(ref.context);

    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        ref.read(_dashboardTabIndexProvider.notifier).state = index;
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          icon,
          color: isSelected
              ? theme.colorScheme.primary
              : Colors.grey.withOpacity(0.6),
          size: 28,
        ),
      ),
    );
  }
}
