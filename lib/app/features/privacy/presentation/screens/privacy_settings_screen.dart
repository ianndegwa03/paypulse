import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paypulse/app/features/privacy/presentation/state/privacy_provider.dart';
import 'package:paypulse/app/features/auth/presentation/state/auth_notifier.dart';
import 'package:paypulse/app/features/wallet/presentation/state/currency_provider.dart';
import 'package:paypulse/domain/entities/enums.dart';

class PrivacySettingsScreen extends ConsumerWidget {
  const PrivacySettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final privacyState = ref.watch(privacyProvider);
    final user = ref.watch(authNotifierProvider).currentUser;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Privacy & Security',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (user != null) ...[
            _buildUserHeader(context, user),
            const SizedBox(height: 32),
          ],
          _buildSectionHeader(context, 'Visibility'),
          const SizedBox(height: 12),
          _buildCard(
            context,
            children: [
              _buildSwitchTile(
                context,
                title: 'Hide Balance',
                subtitle: 'Mask your balance on the home screen',
                icon: Icons.visibility_off_outlined,
                value: privacyState.isBalanceHidden,
                onChanged: (val) {
                  HapticFeedback.selectionClick();
                  ref.read(privacyProvider.notifier).toggleBalanceVisibility();
                },
              ),
              const Divider(indent: 50),
              _buildSwitchTile(
                context,
                title: 'App Switcher Blur',
                subtitle: 'Blur content when switching apps',
                icon: Icons.blur_on_rounded,
                value: privacyState.isAppBlurEnabled,
                onChanged: (val) {
                  HapticFeedback.selectionClick();
                  ref.read(privacyProvider.notifier).toggleAppBlur();
                },
              ),
            ],
          ),
          const SizedBox(height: 32),
          _buildSectionHeader(context, 'Security'),
          const SizedBox(height: 12),
          _buildCard(
            context,
            children: [
              _buildActionTile(
                context,
                title: 'Change PIN',
                icon: Icons.lock_outline_rounded,
                onTap: () {
                  HapticFeedback.lightImpact();
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text('PIN Flow')));
                },
              ),
            ],
          ),
          const SizedBox(height: 32),
          _buildSectionHeader(context, 'Data Management'),
          const SizedBox(height: 12),
          _buildCard(
            context,
            children: [
              _buildSwitchTile(
                context,
                title: 'Incognito Mode',
                subtitle: 'Send money anonymously',
                icon: Icons.vpn_lock_rounded,
                value: privacyState.isIncognitoMode,
                onChanged: (val) {
                  HapticFeedback.selectionClick();
                  ref.read(privacyProvider.notifier).toggleIncognito();
                },
              ),
              const Divider(indent: 50),
              _buildCurrencyTile(context, ref),
            ],
          ),
          const SizedBox(height: 48),
          Center(
            child: TextButton.icon(
              onPressed: () {
                HapticFeedback.heavyImpact();
              },
              icon: const Icon(Icons.delete_forever, color: Colors.red),
              label: const Text('Delete Account',
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Colors.grey,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
    );
  }

  Widget _buildCard(BuildContext context, {required List<Widget> children}) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile(BuildContext context,
      {required String title,
      required String subtitle,
      required IconData icon,
      required bool value,
      required ValueChanged<bool> onChanged}) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: theme.colorScheme.primary, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: theme.textTheme.bodySmall),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeColor: theme.colorScheme.primary,
      ),
    );
  }

  Widget _buildUserHeader(BuildContext context, user) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
            child: Text(
                (user.firstName.isNotEmpty ? user.firstName[0] : '?')
                    .toUpperCase(),
                style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 24)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.fullName,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18)),
                Text('@${user.username}',
                    style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyTile(BuildContext context, WidgetRef ref) {
    final selectedCurrency = ref.watch(currencyProvider).selectedCurrency;
    return ListTile(
      onTap: () => _showCurrencyPicker(context, ref),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.currency_exchange_rounded,
            color: Colors.orange, size: 22),
      ),
      title: const Text('Local Currency',
          style: TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(selectedCurrency.name,
          style: Theme.of(context).textTheme.bodySmall),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(selectedCurrency.name,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.grey)),
          const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20),
        ],
      ),
    );
  }

  void _showCurrencyPicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Select Currency",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            ...CurrencyType.values.map((c) {
              final meta = getCurrencyMetadata(c);
              return ListTile(
                leading: Text(meta.symbol,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                title: Text(meta.name),
                trailing: Text(c.name),
                onTap: () {
                  ref.read(currencyProvider.notifier).setCurrency(c);
                  Navigator.of(context).pop();
                },
              );
            }).toList(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile(BuildContext context,
      {required String title,
      required IconData icon,
      required VoidCallback onTap}) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.grey.shade600, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
    );
  }
}
