import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paypulse/app/features/dashboard/presentation/screens/home_tab_screen.dart';
import 'package:paypulse/app/features/dashboard/presentation/screens/insights_tab_screen.dart';
import 'package:paypulse/app/features/social/presentation/screens/social_tab_screen.dart';
import 'package:paypulse/app/features/dashboard/presentation/screens/wallet_tab_screen.dart';
import 'package:paypulse/app/features/social/presentation/screens/chat_list_screen.dart';

import 'package:paypulse/app/features/dashboard/presentation/widgets/floating_nav_bar.dart';

final _dashboardTabIndexProvider = StateProvider<int>((ref) => 0);

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  late PageController _horizontalPageController;

  @override
  void initState() {
    super.initState();
    _horizontalPageController = PageController();
  }

  @override
  void dispose() {
    _horizontalPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(_dashboardTabIndexProvider);

    final tabs = [
      const HomeTabScreen(),
      const SocialTabScreen(),
      const WalletTabScreen(),
      const InsightsTabScreen(),
    ];

    DateTime? currentBackPressTime;

    return WillPopScope(
      onWillPop: () async {
        final now = DateTime.now();
        if (selectedIndex != 0) {
          // If not on Home tab, go back to Home first
          ref.read(_dashboardTabIndexProvider.notifier).state = 0;
          return false;
        }

        if (currentBackPressTime == null ||
            now.difference(currentBackPressTime!) >
                const Duration(seconds: 2)) {
          currentBackPressTime = now;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Press back again to exit'),
              duration: Duration(seconds: 2),
            ),
          );
          return false;
        }
        return true;
      },
      child: Scaffold(
        extendBody: true,
        body: PageView(
          controller: _horizontalPageController,
          physics: const ClampingScrollPhysics(),
          children: [
            // Main Dashboard with Tabs
            Scaffold(
              extendBody: true,
              backgroundColor:
                  Colors.transparent, // Important for extending body
              body: tabs[selectedIndex],
              bottomNavigationBar: FloatingNavBar(
                selectedIndex: selectedIndex,
                onItemSelected: (index) {
                  HapticFeedback.lightImpact();
                  ref.read(_dashboardTabIndexProvider.notifier).state = index;
                },
              ),
            ),
            // Swipe to Inbox
            const ChatListScreen(),
          ],
        ),
      ),
    );
  }
}
