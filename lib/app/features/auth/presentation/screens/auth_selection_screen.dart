import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:paypulse/app/features/auth/presentation/state/auth_notifier.dart';
import 'dart:ui';

class AuthSelectionScreen extends ConsumerWidget {
  const AuthSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          // Premium Gradient Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.scaffoldBackgroundColor,
                  theme.colorScheme.primary.withOpacity(0.05),
                  theme.scaffoldBackgroundColor,
                ],
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),

                  // App Logo / Icon
                  Hero(
                    tag: 'app_logo',
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withOpacity(0.2),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.lock_person_rounded,
                        size: 64,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  )
                      .animate()
                      .scale(duration: 600.ms, curve: Curves.easeOutBack),

                  const SizedBox(height: 48),

                  Text(
                    "Welcome Back",
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),

                  const SizedBox(height: 12),

                  Text(
                    "Select a secure method to unlock your wallet",
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ).animate().fadeIn(delay: 300.ms),

                  const Spacer(),

                  // Auth Options List
                  _buildAuthOption(
                    context,
                    title: "Biometric Unlock",
                    subtitle: "Face ID or Fingerprint",
                    icon: Icons.face_retouching_natural_rounded,
                    color: theme.colorScheme.primary,
                    onTap: () => ref
                        .read(authNotifierProvider.notifier)
                        .loginWithBiometrics(),
                  ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.1),

                  const SizedBox(height: 16),

                  _buildAuthOption(
                    context,
                    title: "Passcode PIN",
                    subtitle: "4-digit security code",
                    icon: Icons.dialpad_rounded,
                    color: Colors.orange,
                    onTap: () => context.push('/pin-login'),
                  ).animate().fadeIn(delay: 500.ms).slideX(begin: 0.1),

                  const SizedBox(height: 16),

                  _buildAuthOption(
                    context,
                    title: "Classic Login",
                    subtitle: "Password credentials",
                    icon: Icons.password_rounded,
                    color: Colors.blue,
                    onTap: () => context.push('/login'),
                  ).animate().fadeIn(delay: 600.ms).slideX(begin: -0.1),

                  const SizedBox(height: 48),

                  TextButton(
                    onPressed: () =>
                        ref.read(authNotifierProvider.notifier).logout(),
                    child: const Text("Not you? Sign Out"),
                  ).animate().fadeIn(delay: 800.ms),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Error Display
          if (authState.errorMessage != null)
            Positioned(
              bottom: 100,
              left: 32,
              right: 32,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  authState.errorMessage!,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ).animate().shake(),
            ),
        ],
      ),
    );
  }

  Widget _buildAuthOption(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
            ),
            color: isDark
                ? Colors.white.withOpacity(0.03)
                : Colors.black.withOpacity(0.02),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: theme.textTheme.bodySmall?.color,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: theme.dividerColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
