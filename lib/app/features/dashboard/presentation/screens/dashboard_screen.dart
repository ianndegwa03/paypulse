import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paypulse/app/features/dashboard/presentation/screens/home_tab_screen.dart';
import 'package:paypulse/app/features/dashboard/presentation/screens/insights_tab_screen.dart';
import 'package:paypulse/app/features/dashboard/presentation/screens/transactions_tab_screen.dart';
import 'package:paypulse/app/features/wallet/presentation/screens/wallet_overview_screen.dart';
import 'package:paypulse/core/theme/theme_provider.dart';

final _dashboardTabs = [
  const HomeTabScreen(),
  const TransactionsTabScreen(),
  const WalletOverviewScreen(),
  const InsightsTabScreen(),
  const Scaffold(body: Center(child: Text('Profile Tab'))),
];

final _dashboardTabIndexProvider = StateProvider<int>((ref) => 0);

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(_dashboardTabIndexProvider);

    return Scaffold(
      body: _dashboardTabs[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) => ref.read(_dashboardTabIndexProvider.notifier).state = index,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.swap_horiz), label: 'Transactions'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'Wallet'),
          BottomNavigationBarItem(icon: Icon(Icons.insights), label: 'Insights'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref.read(themeProvider.notifier).toggleTheme();
        },
        child: const Icon(Icons.brightness_6),
      ),
    );
  }
}
