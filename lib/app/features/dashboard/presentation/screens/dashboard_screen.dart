import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paypulse/app/features/dashboard/presentation/screens/home_tab_screen.dart';
import 'package:paypulse/app/features/dashboard/presentation/screens/insights_tab_screen.dart';
import 'package:paypulse/app/features/dashboard/presentation/screens/wallet_tab_screen.dart';
import 'package:paypulse/app/features/dashboard/presentation/screens/community_tab_screen.dart';
import 'package:paypulse/app/features/dashboard/presentation/widgets/floating_nav_bar.dart';
import 'package:paypulse/app/features/dashboard/presentation/widgets/pulse_action_hub.dart';

final _dashboardTabIndexProvider = StateProvider<int>((ref) => 0);

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(_dashboardTabIndexProvider);
    final theme = Theme.of(context);

    final tabs = [
      const HomeTabScreen(),
      const WalletTabScreen(),
      const InsightsTabScreen(),
      const CommunityTabScreen(),
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Content
          Positioned.fill(
            child: Container(
              color: theme.scaffoldBackgroundColor,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: tabs[selectedIndex],
              ),
            ),
          ),

          // Custom Floating Dock
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: FloatingNavBar(
              selectedIndex: selectedIndex,
              onItemSelected: (index) {
                if (index == 4) {
                  // Pulsating Center Hub
                  _showActionHub(context);
                } else {
                  HapticFeedback.lightImpact();
                  ref.read(_dashboardTabIndexProvider.notifier).state = index;
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showActionHub(BuildContext context) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const PulseActionHub(),
    );
  }
}
