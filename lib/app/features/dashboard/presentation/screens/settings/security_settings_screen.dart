import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paypulse/app/features/auth/presentation/state/auth_notifier.dart';
import 'package:local_auth/local_auth.dart';
import 'package:go_router/go_router.dart';

class SecuritySettingsScreen extends ConsumerWidget {
  const SecuritySettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.currentUser;
    final theme = Theme.of(context);

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Security Settings')),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Biometrics',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SwitchListTile(
            title: const Text('Biometric Log in'),
            subtitle: const Text('Enable Fingerprint/Face ID for faster login'),
            value: user.hasBiometricEnabled,
            onChanged: (val) async {
              if (val) {
                final LocalAuthentication auth = LocalAuthentication();
                try {
                  final bool canAuthenticate = await auth.isDeviceSupported() ||
                      await auth.canCheckBiometrics;

                  if (!canAuthenticate) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Biometrics not available on this device')),
                      );
                    }
                    return;
                  }

                  // Clean local_auth v3 implementation
                  try {
                    final bool didAuthenticate = await auth.authenticate(
                      localizedReason:
                          'Please authenticate to enable biometric login',
                      biometricOnly: true,
                      persistAcrossBackgrounding: true,
                    );

                    if (!didAuthenticate) return;
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Authentication Error: $e')),
                      );
                    }
                    return;
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Authentication error: $e')),
                    );
                  }
                  return;
                }
              }
              await ref
                  .read(authNotifierProvider.notifier)
                  .enableBiometric(val);
            },
            secondary: const Icon(Icons.fingerprint),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.assignment_ind_rounded),
            title: const Text('Identity Configuration'),
            subtitle: const Text('Manage Face ID & Fingerprints'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => context.push('/identity-config'),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Authentication',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('Change Password'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text(
                        "Please sign out and use 'Forgot Password' to reset.")),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.verified_user_outlined),
            title: const Text('Two-Factor Authentication'),
            subtitle: const Text('Currently unavailable'),
            trailing: const Icon(Icons.lock, size: 16, color: Colors.grey),
            enabled: false,
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.delete_forever, color: theme.colorScheme.error),
            title: Text('Delete Account',
                style: TextStyle(color: theme.colorScheme.error)),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text("Contact support to delete account")),
              );
            },
          ),
        ],
      ),
    );
  }
}
