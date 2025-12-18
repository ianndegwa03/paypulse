import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:paypulse/app/features/admin/presentation/state/admin_notifier.dart';
import 'package:paypulse/domain/entities/admin_settings_entity.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adminProvider);
    final notifier = ref.read(adminProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.errorMessage != null
              ? Center(child: Text('Error: ${state.errorMessage}'))
              : _buildSettingsList(context, state.settings!, notifier),
    );
  }

  Widget _buildSettingsList(
    BuildContext context,
    AdminSettingsEntity settings,
    AdminNotifier notifier,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildSectionHeader('Feature Management'),
        _buildSwitchTile(
          'Investments',
          'Enable or disable investment features',
          settings.isInvestmentEnabled,
          (val) => notifier.toggleFeature('investment'),
        ),
        _buildSwitchTile(
          'Crypto',
          'Enable or disable cryptocurrency features',
          settings.isCryptoEnabled,
          (val) => notifier.toggleFeature('crypto'),
        ),
        _buildSwitchTile(
          'Savings',
          'Enable or disable savings goals',
          settings.isSavingsEnabled,
          (val) => notifier.toggleFeature('savings'),
        ),
        _buildSwitchTile(
          'Bills',
          'Enable or disable bill payments',
          settings.isBillsEnabled,
          (val) => notifier.toggleFeature('bills'),
        ),
        _buildSwitchTile(
          'Social',
          'Enable or disable social feed',
          settings.isSocialEnabled,
          (val) => notifier.toggleFeature('social'),
        ),
        const Divider(height: 32),
        _buildSectionHeader('System Control'),
        Card(
          color: settings.isMaintenanceMode ? Colors.red.shade50 : null,
          child: SwitchListTile(
            title: const Text(
              'Maintenance Mode',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
            ),
            subtitle: const Text(
                'Restrict access to the app for all non-admin users'),
            value: settings.isMaintenanceMode,
            onChanged: (val) => notifier.toggleFeature('maintenance'),
            activeThumbColor: Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }
}
