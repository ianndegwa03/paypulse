import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paypulse/app/features/privacy/presentation/state/privacy_provider.dart';

class PrivacySecurityControlsScreen extends ConsumerWidget {
  const PrivacySecurityControlsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final privacyState = ref.watch(privacyProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Advanced Controls'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        physics: const BouncingScrollPhysics(),
        children: [
          _buildHeader(theme),
          const SizedBox(height: 32),
          _buildSection(context, 'Data & Visibility', [
            _buildSwitchTile(
              context,
              title: 'Incognito Mode',
              subtitle: 'Transactions won\'t show your real name',
              icon: Icons.vpn_lock_rounded,
              value: privacyState.isIncognitoMode,
              onChanged: (val) =>
                  ref.read(privacyProvider.notifier).toggleIncognito(),
            ),
            const Divider(indent: 56),
            _buildSwitchTile(
              context,
              title: 'Mask Balance',
              subtitle: 'Hide total balance from main dashboard',
              icon: Icons.visibility_off_outlined,
              value: privacyState.isBalanceHidden,
              onChanged: (val) =>
                  ref.read(privacyProvider.notifier).toggleBalanceVisibility(),
            ),
          ]),
          const SizedBox(height: 24),
          _buildSection(context, 'User Freedom & Data', [
            _buildActionTile(
              context,
              title: 'Download My Data',
              subtitle: 'Get a copy of all your transaction history',
              icon: Icons.download_rounded,
              onTap: () => _showComingSoon(context),
            ),
            const Divider(indent: 56),
            _buildActionTile(
              context,
              title: 'Request Data Deletion',
              subtitle: 'Permanently remove specific records',
              icon: Icons.delete_outline_rounded,
              onTap: () => _showComingSoon(context),
            ),
          ]),
          const SizedBox(height: 24),
          _buildSection(context, 'Advanced Security', [
            _buildActionTile(
              context,
              title: 'Login Activity',
              subtitle: 'Monitor recent logins and devices',
              icon: Icons.devices_other_rounded,
              onTap: () => _showComingSoon(context),
            ),
            const Divider(indent: 56),
            _buildSwitchTile(
              context,
              title: 'App Switcher Protection',
              subtitle: 'Blur app content in recent tasks',
              icon: Icons.blur_linear_rounded,
              value: privacyState.isAppBlurEnabled,
              onChanged: (val) =>
                  ref.read(privacyProvider.notifier).toggleAppBlur(),
            ),
          ]),
          const SizedBox(height: 48),
          _buildSecurityNote(theme),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Privacy & Freedom',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Manage how your data is used and how you appear to others on PayPulse.',
          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildSection(
      BuildContext context, String title, List<Widget> children) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            border:
                Border.all(color: theme.colorScheme.outline.withOpacity(0.05)),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: theme.colorScheme.primary, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle,
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
      trailing: Switch.adaptive(
        value: value,
        onChanged: (val) {
          HapticFeedback.selectionClick();
          onChanged(val);
        },
        activeColor: theme.colorScheme.primary,
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return ListTile(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: theme.colorScheme.secondary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: theme.colorScheme.secondary, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle,
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
      trailing:
          const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20),
    );
  }

  Widget _buildSecurityNote(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.error.withOpacity(0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.error.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(Icons.gpp_maybe_rounded, color: theme.colorScheme.error),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Your financial data is encrypted and never shared with third parties without your explicit consent.',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content:
              Text('This feature is being rolled out for your region soon.')),
    );
  }
}
