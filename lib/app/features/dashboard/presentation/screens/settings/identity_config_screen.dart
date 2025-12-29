import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:paypulse/app/di/injector.dart';
import 'package:paypulse/core/services/biometric/biometric_service.dart';
import 'package:paypulse/app/features/auth/presentation/state/auth_notifier.dart';

class IdentityConfigScreen extends ConsumerStatefulWidget {
  const IdentityConfigScreen({super.key});

  @override
  ConsumerState<IdentityConfigScreen> createState() =>
      _IdentityConfigScreenState();
}

class _IdentityConfigScreenState extends ConsumerState<IdentityConfigScreen> {
  final _biometricService = getIt<BiometricService>();
  List<BiometricType> _availableBiometrics = [];
  bool _isLoading = true;
  bool _persistCredentials = false;
  bool _usePin = false;

  @override
  void initState() {
    super.initState();
    _loadBiometricData();
    // Initialize from current state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _persistCredentials = ref.read(authNotifierProvider).isBiometricEnabled;
        _usePin = ref.read(authNotifierProvider).isPinEnabled;
      });
    });
  }

  Future<void> _loadBiometricData() async {
    final types = await _biometricService.getAvailableBiometrics();
    if (mounted) {
      setState(() {
        _availableBiometrics = types;
        _isLoading = false;
      });
    }
  }

  Future<void> _testIdentity(BiometricType type) async {
    HapticFeedback.mediumImpact();
    try {
      final authenticated = await _biometricService.authenticate(
        reason: 'Confirming your ${type.name} for secure access',
      );

      if (authenticated && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white),
                const SizedBox(width: 12),
                Text('${type.name} verified successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Verification failed: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Identity Configuration'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildHeader(theme),
                const SizedBox(height: 32),
                _buildSectionTitle(theme, 'Detection Result'),
                const SizedBox(height: 16),
                ..._availableBiometrics
                    .map((type) => _buildBiometricTile(theme, type))
                    .toList(),
                if (_availableBiometrics.isEmpty)
                  _buildInfoCard(
                      theme,
                      'No biometric hardware detected on this device.',
                      Icons.warning_amber_rounded,
                      Colors.orange),
                const SizedBox(height: 32),
                _buildSectionTitle(theme, 'Identity Persistence'),
                const SizedBox(height: 16),
                _buildPersistenceToggle(theme),
                const SizedBox(height: 16),
                _buildPinToggle(theme),
                const SizedBox(height: 24),
                _buildSecurityTip(theme),
              ],
            ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.shield_rounded,
              size: 64, color: theme.colorScheme.primary),
        ),
        const SizedBox(height: 24),
        Text(
          'Manage Your Digital Identity',
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Choose your preferred method for quick and secure access to your wallet.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Text(
      title.toUpperCase(),
      style: theme.textTheme.labelMedium?.copyWith(
        color: Colors.grey,
        letterSpacing: 1.2,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildBiometricTile(ThemeData theme, BiometricType type) {
    IconData icon;
    String label;
    String description;

    switch (type) {
      case BiometricType.face:
        icon = Icons.face_retouching_natural_rounded;
        label = 'Face Recognition';
        description = 'Fastest identity verification';
        break;
      case BiometricType.fingerprint:
        icon = Icons.fingerprint_rounded;
        label = 'Fingerprint Scan';
        description = 'Highly secure physical identity';
        break;
      case BiometricType.iris:
        icon = Icons.remove_red_eye_rounded;
        label = 'Iris Scan';
        description = 'Advanced biological verification';
        break;
      default:
        icon = Icons.security_rounded;
        label = type.name;
        description = 'Device secure hardware';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: theme.colorScheme.primary),
        ),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
        trailing: OutlinedButton(
          onPressed: () => _testIdentity(type),
          style: OutlinedButton.styleFrom(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('Confirm'),
        ),
      ),
    );
  }

  Widget _buildPersistenceToggle(ThemeData theme) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: SwitchListTile(
          value: _persistCredentials,
          onChanged: (val) {
            if (val) {
              _showPasswordVerificationDialog();
            } else {
              setState(() => _persistCredentials = val);
              HapticFeedback.selectionClick();
              ref.read(authNotifierProvider.notifier).enableBiometric(val);
            }
          },
          title: const Text('Keep me logged in',
              style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle:
              const Text('Use biometrics to bypass email & password entry'),
          secondary:
              Icon(Icons.vpn_key_rounded, color: theme.colorScheme.primary),
        ),
      ),
    );
  }

  Widget _buildPinToggle(ThemeData theme) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: SwitchListTile(
          value: _usePin,
          onChanged: (val) {
            if (val) {
              _showPinSetupDialog();
            } else {
              setState(() => _usePin = val);
              HapticFeedback.selectionClick();
              ref.read(authNotifierProvider.notifier).enablePin(val, null);
            }
          },
          title: const Text('PIN Protection',
              style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: const Text('Use a 4-digit PIN as a backup login method'),
          secondary:
              Icon(Icons.dialpad_rounded, color: theme.colorScheme.primary),
        ),
      ),
    );
  }

  void _showPinSetupDialog() {
    final pinController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Login PIN'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter a 4-digit PIN for quick access.'),
            const SizedBox(height: 16),
            TextField(
              controller: pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 4,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, letterSpacing: 16),
              decoration: const InputDecoration(
                hintText: '••••',
                counterText: '',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final pin = pinController.text;
              if (pin.length != 4) return;

              final notifier = ref.read(authNotifierProvider.notifier);

              await notifier.enablePin(true, pin);

              if (mounted) {
                setState(() => _usePin = true);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('PIN enabled successfully!')),
                );
              }
            },
            child: const Text('Save PIN'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
      ThemeData theme, String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 16),
          Expanded(child: Text(text, style: TextStyle(color: color))),
        ],
      ),
    );
  }

  Widget _buildSecurityTip(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline_rounded, color: Colors.blue, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'For maximum security, always use methods provided by your device hardware. PayPulse never stores your raw biometric data.',
              style: TextStyle(fontSize: 13, color: Colors.blueGrey),
            ),
          ),
        ],
      ),
    );
  }

  void _showPasswordVerificationDialog() {
    final passwordController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Verify Identity'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
                'Please enter your password to enable secure biometric login.'),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final password = passwordController.text;
              if (password.isEmpty) return;

              final notifier = ref.read(authNotifierProvider.notifier);
              final email = ref.read(authNotifierProvider).email;

              // Enable biometric in settings
              await notifier.enableBiometric(true);

              // Save credentials
              try {
                final creds =
                    json.encode({'email': email, 'password': password});
                await _biometricService.saveBiometricCredentials(
                    'default', creds);

                if (mounted) {
                  setState(() => _persistCredentials = true);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Biometric login enabled!')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
