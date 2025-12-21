import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:paypulse/app/features/auth/presentation/state/auth_notifier.dart';
import 'package:paypulse/core/theme/theme_provider.dart';
import 'package:paypulse/core/widgets/buttons/primary_button.dart';

class ProfileTabScreen extends ConsumerWidget {
  const ProfileTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.currentUser;
    final theme = Theme.of(context);
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      // No AppBar, we'll use a custom header or Sliver later. For now standard list.
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 200,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.secondary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 48), // Space for status bar
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: theme.colorScheme.surface,
                        backgroundImage: user.profileImageUrl != null
                            ? NetworkImage(user.profileImageUrl!)
                            : null,
                        child: user.profileImageUrl == null
                            ? Text(
                                user.firstName.isNotEmpty
                                    ? user.firstName[0].toUpperCase()
                                    : '?',
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        user.fullName,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white, // Always white on gradient
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '@${user.firstName.toLowerCase()}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // --- ACCOUNT SETTINGS ---
                  _buildSectionHeader(context, 'Account'),
                  _buildListTile(
                    context,
                    icon: Icons.person_outline,
                    title: 'Edit Profile',
                    subtitle: 'Update details & photo',
                    onTap: () => context.push('/edit-profile'),
                  ),
                  _buildListTile(
                    context,
                    icon: Icons.badge_outlined,
                    title: 'Verification',
                    subtitle: user.isEmailVerified ? 'Verified' : 'Unverified',
                    trailing: user.isEmailVerified
                        ? Icon(Icons.check_circle, color: Colors.green)
                        : Icon(Icons.warning_amber_rounded,
                            color: Colors.orange),
                    onTap: () {},
                  ),

                  const SizedBox(height: 24),

                  // --- APPEARANCE & APP SETTINGS ---
                  _buildSectionHeader(context, 'Preferences'),
                  SwitchListTile(
                    title: const Text('Dark Mode'),
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.purple.withOpacity(0.1)
                            : Colors.amber.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        isDark ? Icons.dark_mode : Icons.light_mode,
                        color: isDark ? Colors.purple : Colors.amber,
                      ),
                    ),
                    value: isDark,
                    onChanged: (value) {
                      ref.read(themeProvider.notifier).toggleTheme();
                    },
                  ),
                  _buildListTile(
                    context,
                    icon: Icons.notifications_none_rounded,
                    title: 'Notifications',
                    onTap: () {},
                  ),
                  _buildListTile(
                    context,
                    icon: Icons.security,
                    title: 'Security',
                    subtitle: 'Biometrics, PIN, Password',
                    onTap: () => context.push('/security-settings'),
                  ),

                  const SizedBox(height: 24),

                  // --- SUPPORT ---
                  _buildSectionHeader(context, 'Support'),
                  _buildListTile(
                    context,
                    icon: Icons.help_outline,
                    title: 'Help Center',
                    onTap: () {},
                  ),
                  _buildListTile(
                    context,
                    icon: Icons.info_outline,
                    title: 'About PayPulse',
                    onTap: () {},
                  ),

                  const SizedBox(height: 32),

                  // --- ACTIONS ---
                  PrimaryButton(
                    onPressed: () {
                      _showLogoutDialog(context, ref);
                    },
                    label: 'Sign Out',
                    backgroundColor: theme.colorScheme.error.withOpacity(0.1),
                    textColor: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      'v1.0.0 (Build 100)',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: theme.cardColor,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withAlpha(
                20), // using withAlpha for safety or just withOpacity
            // withValues(alpha: 0.1) is newer flutter. using withOpacity for now.
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: theme.colorScheme.primary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: subtitle != null
            ? Text(subtitle, style: theme.textTheme.bodySmall)
            : null,
        trailing: trailing ??
            const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.pop();
              ref.read(authNotifierProvider.notifier).logout();
              context.go('/login');
            },
            child: const Text('Sign Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
