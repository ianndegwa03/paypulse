import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paypulse/app/features/dashboard/presentation/screens/home_tab_screen.dart';
import 'package:paypulse/app/features/dashboard/presentation/screens/insights_tab_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:paypulse/app/features/dashboard/presentation/screens/transactions_tab_screen.dart';
import 'package:paypulse/app/features/wallet/presentation/screens/wallet_overview_screen.dart';
import 'package:paypulse/app/features/dashboard/presentation/screens/profile_tab_screen.dart';
import 'package:paypulse/app/features/auth/presentation/state/auth_notifier.dart';
import 'package:paypulse/domain/entities/enums.dart';

final _dashboardTabs = [
  const HomeTabScreen(),
  const TransactionsTabScreen(),
  const WalletOverviewScreen(),
  const InsightsTabScreen(),
  const ProfileTabScreen(),
];

final _dashboardTabIndexProvider = StateProvider<int>((ref) => 0);

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(_dashboardTabIndexProvider);
    final theme = Theme.of(context);

    final authState = ref.watch(authNotifierProvider);
    final user = authState.currentUser;
    final isAdmin = user?.role == UserRole.admin;

    return Scaffold(
      appBar: selectedIndex !=
              4 // Hide AppBar on Profile tab (it has its own SliverAppBar)
          ? AppBar(
              title: const Text('PayPulse'),
              actions: [
                if (isAdmin)
                  IconButton(
                    icon: const Icon(Icons.admin_panel_settings),
                    tooltip: 'Admin Panel',
                    onPressed: () => context.push('/admin'),
                  ),
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {},
                ),
              ],
            )
          : null,
      body: _dashboardTabs[selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) =>
            ref.read(_dashboardTabIndexProvider.notifier).state = index,
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        indicatorColor: theme.colorScheme.primaryContainer,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.swap_horiz_outlined),
            selectedIcon: Icon(Icons.swap_horiz),
            label: 'Activity',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: 'Wallet',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: 'Insights',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
