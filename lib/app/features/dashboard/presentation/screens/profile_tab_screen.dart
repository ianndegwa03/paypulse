import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:paypulse/app/features/auth/presentation/state/auth_notifier.dart';
import 'package:paypulse/core/theme/app_colors.dart';
import 'package:paypulse/app/features/pro/presentation/state/pro_providers.dart';
import 'package:paypulse/app/features/social/presentation/state/trust_provider.dart';

class ProfileTabScreen extends ConsumerWidget {
  const ProfileTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.currentUser;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context, user, theme, ref),
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildActionList(context, theme, ref),
                const SizedBox(height: 32),
                _buildDangerZone(context, theme, ref),
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(
      BuildContext context, dynamic user, ThemeData theme, WidgetRef ref) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: AppColors.premiumGradient,
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    backgroundImage: user?.profileImageUrl != null &&
                            user!.profileImageUrl!.isNotEmpty
                        ? NetworkImage(user!.profileImageUrl!)
                        : null,
                    child: user?.profileImageUrl == null ||
                            user!.profileImageUrl!.isEmpty
                        ? Text(
                            user?.firstName != null &&
                                    user!.firstName!.isNotEmpty
                                ? user!.firstName![0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                                fontSize: 32,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          )
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${user?.firstName ?? ''} ${user?.lastName ?? ''}'.trim() !=
                            ''
                        ? '${user?.firstName} ${user?.lastName}'
                        : user?.username ?? 'Anonymous User',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    user?.email?.value ?? '',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSocialStats(ref, user?.id ?? ''),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit_rounded, color: Colors.white),
          onPressed: () => context.push('/edit-profile'),
        ),
      ],
    );
  }

  Widget _buildSocialStats(WidgetRef ref, String userId) {
    if (userId.isEmpty) return const SizedBox.shrink();

    final trustState = ref.watch(trustProvider(userId));

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStatItem("0", "Friends"),
        _buildStatDivider(),
        _buildStatItem("0", "Following"),
        _buildStatDivider(),
        _buildStatItem(trustState.vouchCount.toString(), "Vouches"),
      ],
    );
  }

  Widget _buildStatItem(String count, String label) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 11,
              fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      height: 20,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      color: Colors.white.withOpacity(0.2),
    );
  }

  Widget _buildActionList(
      BuildContext context, ThemeData theme, WidgetRef ref) {
    final isProMode = ref.watch(proModeProvider).valueOrNull ?? false;

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 24),
          decoration: BoxDecoration(
            gradient: isProMode
                ? const LinearGradient(colors: [Colors.black, Colors.black87])
                : null,
            color: isProMode ? null : theme.cardColor,
            borderRadius: BorderRadius.circular(20),
            border:
                Border.all(color: theme.colorScheme.outline.withOpacity(0.05)),
            boxShadow: isProMode
                ? [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5))
                  ]
                : null,
          ),
          child: SwitchListTile(
            value: isProMode,
            onChanged: (val) {
              ref.read(proServiceProvider).toggleProMode(val);
            },
            title: Text("Pro Mode",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isProMode
                        ? Colors.white
                        : theme.textTheme.bodyMedium?.color)),
            subtitle: Text("Freelancer tools & analytics",
                style: TextStyle(
                    fontSize: 12,
                    color: isProMode
                        ? Colors.white70
                        : theme.textTheme.bodySmall?.color)),
            activeColor: Colors.white,
            activeTrackColor: Colors.grey.shade800,
            secondary: Icon(Icons.work_rounded,
                color: isProMode ? Colors.white : theme.colorScheme.primary),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
        ),
        _buildProfileItem(
          theme,
          icon: Icons.security_rounded,
          title: 'Security & Privacy',
          onTap: () => context.push('/security-settings'),
        ),
        _buildProfileItem(
          theme,
          icon: Icons.palette_rounded,
          title: 'Theme Settings',
          onTap: () => context.push('/theme-settings'),
        ),
        _buildProfileItem(
          theme,
          icon: Icons.help_outline_rounded,
          title: 'Support',
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildProfileItem(
    ThemeData theme, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.05)),
      ),
      child: ListTile(
        leading: Icon(icon, color: theme.colorScheme.primary),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        trailing: const Icon(Icons.chevron_right_rounded, size: 18),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  Widget _buildDangerZone(
      BuildContext context, ThemeData theme, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.red.withOpacity(0.1)),
      ),
      child: ListTile(
        leading: const Icon(Icons.logout_rounded, color: Colors.red),
        title: const Text('Logout',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        onTap: () async {
          await ref.read(authNotifierProvider.notifier).logout();
          if (context.mounted) {
            context.go('/login');
          }
        },
      ),
    );
  }
}
