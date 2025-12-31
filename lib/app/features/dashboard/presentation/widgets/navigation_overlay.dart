import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paypulse/app/features/auth/presentation/state/auth_notifier.dart';

class NavigationOverlay extends ConsumerWidget {
  const NavigationOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final user = ref.watch(authNotifierProvider).currentUser;

    return Material(
      color: Colors.transparent,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          color: isDark
              ? Colors.black.withOpacity(0.9)
              : Colors.white.withOpacity(0.9),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Close Button
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Menu",
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 32),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),

                // Account Switcher Stub
                _buildAccountSwitcher(context, user),
                const Divider(),

                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 20),
                    children: [
                      _buildSectionHeader(theme, "Explore"),
                      _buildMenuItem(
                        context,
                        icon: Icons.flag_rounded,
                        title: "Financial Goals",
                        subtitle: "Track your targets",
                        onTap: () {
                          Navigator.of(context).pop();
                          context.push('/goals');
                        },
                      ),
                      _buildMenuItem(
                        context,
                        icon: Icons.groups_rounded,
                        title: "Communities",
                        subtitle: "Finance hubs you follow",
                        onTap: () {
                          Navigator.of(context).pop();
                          context.go('/dashboard');
                        },
                      ),
                      _buildSectionHeader(theme, "Personal"),
                      _buildMenuItem(
                        context,
                        icon: Icons.notifications_none_rounded,
                        title: "Notifications",
                        subtitle: "Manage alerts",
                        onTap: () {
                          Navigator.of(context).pop();
                          context.push('/notifications');
                        },
                      ),
                      _buildMenuItem(
                        context,
                        icon: Icons.qr_code_rounded,
                        title: "My Profile Link",
                        subtitle: "Share your identity",
                        onTap: () {
                          Navigator.of(context).pop();
                          context.push('/scan');
                        },
                      ),
                      _buildSectionHeader(theme, "System"),
                      _buildMenuItem(
                        context,
                        icon: Icons.help_outline_rounded,
                        title: "Support Center",
                        subtitle: "Get help & feedback",
                        onTap: () {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Support chat opening...")));
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildMenuItem(
                        context,
                        icon: Icons.logout_rounded,
                        title: "Logout",
                        subtitle: "Sign out of ${user?.firstName ?? 'account'}",
                        color: Colors.red,
                        onTap: () async {
                          await ref
                              .read(authNotifierProvider.notifier)
                              .logout();
                          if (context.mounted) {
                            context.go('/login');
                          }
                        },
                      ),
                    ]
                        .animate(interval: 50.ms)
                        .fadeIn(duration: 300.ms)
                        .slideX(begin: -0.1, end: 0),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Center(
                    child: Text(
                      "PayPulse System v2.2.0",
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAccountSwitcher(BuildContext context, dynamic user) {
    final theme = Theme.of(context);
    final initials = (user?.firstName?.isNotEmpty == true)
        ? user!.firstName![0].toUpperCase()
        : 'U';
    final displayName = user?.firstName ?? user?.username ?? 'User';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.dividerColor.withOpacity(0.1))),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
              backgroundImage: user?.profileImageUrl != null &&
                      user!.profileImageUrl!.isNotEmpty
                  ? NetworkImage(user!.profileImageUrl!)
                  : null,
              child: user?.profileImageUrl == null ||
                      user!.profileImageUrl!.isEmpty
                  ? Text(initials,
                      style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold))
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(displayName,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(user?.email.value ?? '',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600))
              ],
            )),
            IconButton(
              icon: const Icon(Icons.swap_horiz_rounded),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Account switching coming soon!")));
              },
              tooltip: "Switch Account",
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: Text(title.toUpperCase(),
          style: TextStyle(
              color: theme.colorScheme.primary,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2)),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? color,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (color ?? theme.colorScheme.primary).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon,
                  color: color ?? theme.colorScheme.primary, size: 24),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: Colors.grey.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }
}
