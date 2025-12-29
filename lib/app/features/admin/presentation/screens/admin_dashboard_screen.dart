import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paypulse/app/features/admin/presentation/widgets/user_management_view.dart';
import 'package:paypulse/app/features/admin/presentation/state/admin_notifier.dart';
import 'package:paypulse/core/theme/design_system_v2.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Admin Command Center",
          style: PulseDesign.getTextTheme(isDark).titleLarge,
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _selectedIndex == 0
          ? _buildOverview(context)
          : const UserManagementView(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Overview',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Users',
          ),
        ],
      ),
    );
  }

  Widget _buildOverview(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final adminState = ref.watch(adminProvider);
    final stats = adminState.stats;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(PulseDesign.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "System Overview",
            style: PulseDesign.getTextTheme(theme.brightness == Brightness.dark)
                .titleLarge,
          ),
          const SizedBox(height: PulseDesign.m),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: PulseDesign.m,
            mainAxisSpacing: PulseDesign.m,
            children: [
              _buildStatCard(context, "Total Users",
                  stats?.totalUsers.toString() ?? "...", Icons.people_outline),
              _buildStatCard(
                  context,
                  "Active txs",
                  stats?.activeTransactions.toString() ?? "...",
                  Icons.swap_horiz),
              _buildStatCard(
                  context,
                  "System Health",
                  "${stats?.systemHealth.toString() ?? "99.9"}%",
                  Icons.health_and_safety),
              _buildStatCard(
                  context,
                  "Pending KYC",
                  stats?.pendingKyc.toString() ?? "...",
                  Icons.admin_panel_settings_outlined),
            ],
          ),
          const SizedBox(height: PulseDesign.xl),
          const SizedBox(height: PulseDesign.xl),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Recent Logs",
                style: PulseDesign.getTextTheme(
                        theme.brightness == Brightness.dark)
                    .titleLarge,
              ),
              IconButton(
                icon: Icon(Icons.refresh,
                    color: theme.colorScheme.onSurface.withOpacity(0.5)),
                onPressed: () {
                  // Trigger refresh if needed
                },
              ),
            ],
          ),
          const SizedBox(height: PulseDesign.m),
          if (adminState.logs.isEmpty)
            Padding(
              padding: const EdgeInsets.all(PulseDesign.m),
              child: Text(
                "No recent system activity found.",
                style: PulseDesign.getTextTheme(isDark).bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5)),
              ),
            )
          else
            ...adminState.logs.take(5).map((log) {
              final timeDiff = DateTime.now().difference(log.timestamp);
              final timeStr = _formatDuration(timeDiff);
              return _buildLogTile(context, log.message, timeStr, log.type);
            }),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inMinutes < 1) return 'Just now';
    if (duration.inMinutes < 60) return '${duration.inMinutes}m ago';
    if (duration.inHours < 24) return '${duration.inHours}h ago';
    return '${duration.inDays}d ago';
  }

  Widget _buildStatCard(
      BuildContext context, String title, String value, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(PulseDesign.m),
      decoration: BoxDecoration(
        color: isDark ? PulseDesign.bgDarkCard : PulseDesign.bgLightCard,
        borderRadius: BorderRadius.circular(PulseDesign.radiusM),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: PulseDesign.primary, size: 32),
          const SizedBox(height: PulseDesign.s),
          Text(
            value,
            style: PulseDesign.getTextTheme(isDark)
                .displayMedium
                ?.copyWith(fontSize: 28),
          ),
          const SizedBox(height: PulseDesign.xs),
          Text(
            title,
            style: PulseDesign.getTextTheme(isDark).bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildLogTile(
      BuildContext context, String title, String time, String type) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color typeColor = PulseDesign.primary;
    if (type == 'ERROR') typeColor = PulseDesign.error;
    if (type == 'WARN') typeColor = PulseDesign.warning;
    if (type == 'SUCCESS') typeColor = PulseDesign.success;

    return Container(
      margin: const EdgeInsets.only(bottom: PulseDesign.s),
      padding: const EdgeInsets.all(PulseDesign.m),
      decoration: BoxDecoration(
        color: isDark ? PulseDesign.bgDarkCard : PulseDesign.bgLightCard,
        borderRadius: BorderRadius.circular(PulseDesign.radiusS),
        border: Border.all(color: typeColor.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 4,
                  decoration:
                      BoxDecoration(color: typeColor, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(title,
                      style: PulseDesign.getTextTheme(isDark).bodyMedium,
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ),
          Text(time, style: PulseDesign.getTextTheme(isDark).labelSmall),
        ],
      ),
    );
  }
}
