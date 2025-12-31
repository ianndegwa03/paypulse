import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paypulse/app/features/security_privacy/presentation/state/security_privacy_notifier.dart';
import 'package:paypulse/app/features/auth/presentation/state/auth_notifier.dart';
import 'package:local_auth/local_auth.dart';
import 'package:go_router/go_router.dart';

class SecurityPrivacyScreen extends ConsumerWidget {
  const SecurityPrivacyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(securityPrivacyProvider);
    final authState = ref.watch(authNotifierProvider);
    final theme = Theme.of(context);
    final user = authState.currentUser;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Security & Privacy',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        children: [
          _buildSectionHeader(theme, "Privacy Control"),
          const SizedBox(height: 12),
          _buildCard(theme, [
            _buildSwitchTile(
              theme,
              title: 'Hide Balance',
              subtitle: 'Mask your assets on the home screen',
              icon: Icons.visibility_off_outlined,
              value: state.isBalanceHidden,
              onChanged: (_) => ref
                  .read(securityPrivacyProvider.notifier)
                  .toggleBalanceVisibility(),
            ),
            const Divider(indent: 56),
            _buildSwitchTile(
              theme,
              title: 'App Switcher Blur',
              subtitle: 'Protect view when switching apps',
              icon: Icons.blur_on_rounded,
              value: state.isAppBlurEnabled,
              onChanged: (_) =>
                  ref.read(securityPrivacyProvider.notifier).toggleAppBlur(),
            ),
            const Divider(indent: 56),
            _buildSwitchTile(
              theme,
              title: 'Incognito Mode',
              subtitle: 'Send money with hidden metadata',
              icon: Icons.vpn_lock_rounded,
              value: state.isIncognitoMode,
              onChanged: (_) =>
                  ref.read(securityPrivacyProvider.notifier).toggleIncognito(),
            ),
          ]),
          const SizedBox(height: 32),
          _buildSectionHeader(theme, "Biometrics & Locking"),
          const SizedBox(height: 12),
          _buildCard(theme, [
            _buildSwitchTile(
              theme,
              title: 'Biometric Access',
              subtitle: 'Unlock PayPulse with Fingerprint/Face ID',
              icon: Icons.fingerprint_rounded,
              value: user?.hasBiometricEnabled ?? false,
              onChanged: (val) async {
                if (val) {
                  await _showBiometricExplainer(context, ref);
                } else {
                  await ref
                      .read(authNotifierProvider.notifier)
                      .enableBiometric(false);
                }
              },
            ),
            const Divider(indent: 56),
            _buildSwitchTile(
              theme,
              title: 'PIN Security',
              subtitle: 'Secure access with a 4-digit PIN',
              icon: Icons.lock_outline_rounded,
              value: authState.isPinEnabled,
              onChanged: (val) async {
                if (val) {
                  context.push('/pin-setup');
                } else {
                  await ref
                      .read(authNotifierProvider.notifier)
                      .enablePin(false, null);
                }
              },
            ),
            const Divider(indent: 56),
            _buildActionTile(
              theme,
              title: 'Auto-Lock Session',
              subtitle: state.autoLockMinutes == 0
                  ? 'Disabled'
                  : 'After ${state.autoLockMinutes} minutes',
              icon: Icons.timer_outlined,
              onTap: () =>
                  _showAutoLockPicker(context, ref, state.autoLockMinutes),
            ),
            const Divider(indent: 56),
            _buildActionTile(
              theme,
              title: 'Privacy Transparency',
              subtitle: 'How we handle your data',
              icon: Icons.info_outline_rounded,
              onTap: () => context.push('/privacy-transparency'),
            ),
          ]),
          const SizedBox(height: 48),
          Center(
            child: TextButton.icon(
              onPressed: () {
                HapticFeedback.heavyImpact();
                // TODO: Implement verified delete flow
              },
              icon: const Icon(Icons.delete_forever_rounded,
                  color: Colors.redAccent),
              label: const Text('Delete Financial Identity',
                  style: TextStyle(
                      color: Colors.redAccent, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showBiometricExplainer(
      BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Enable Biometrics?"),
        content: const Text(
            "PayPulse uses your device's biometric sensors (FaceID/TouchID) ONLY for verifying your identity locally. We never store or see your biometric data."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel")),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Continue")),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success =
          await _authenticate(context, 'Verify identity to enable biometrics');
      if (success && context.mounted) {
        await ref.read(authNotifierProvider.notifier).enableBiometric(true);
      }
    }
  }

  Future<bool> _authenticate(BuildContext context, String reason) async {
    final auth = LocalAuthentication();
    try {
      return await auth.authenticate(
        localizedReason: reason,
      );
    } catch (e) {
      return false;
    }
  }

  void _showAutoLockPicker(BuildContext context, WidgetRef ref, int current) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline, size: 80, color: Colors.white),
            const SizedBox(height: 16),
            const Text(
              "PAYPULSE SECURE",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
            const Text("Auto-Lock Duration",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            ...[0, 1, 5, 15, 30].map((m) => ListTile(
                  title: Text(m == 0 ? 'Immediately' : '$m Minutes'),
                  trailing: current == m
                      ? Icon(Icons.check_circle,
                          color: Theme.of(context).primaryColor)
                      : null,
                  onTap: () {
                    ref.read(securityPrivacyProvider.notifier).setAutoLock(m);
                    Navigator.pop(context);
                  },
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Text(title.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
            color: Colors.grey,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2));
  }

  Widget _buildCard(ThemeData theme, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
          color: theme.cardColor, borderRadius: BorderRadius.circular(24)),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile(ThemeData theme,
      {required String title,
      required String subtitle,
      required IconData icon,
      required bool value,
      required ValueChanged<bool> onChanged}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: theme.colorScheme.primary, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: theme.textTheme.bodySmall),
      trailing: Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeColor: theme.colorScheme.primary),
    );
  }

  Widget _buildActionTile(ThemeData theme,
      {required String title,
      required String subtitle,
      required IconData icon,
      required VoidCallback onTap}) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: theme.colorScheme.primary, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: theme.textTheme.bodySmall),
      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
    );
  }
}
