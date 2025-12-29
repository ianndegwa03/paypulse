import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:paypulse/app/features/auth/presentation/state/auth_notifier.dart';
import 'package:paypulse/app/features/wallet/presentation/state/wallet_providers.dart';
import 'package:paypulse/app/features/wallet/presentation/state/currency_provider.dart';
import 'package:paypulse/core/widgets/buttons/primary_button.dart';

class ProfileTabScreen extends ConsumerWidget {
  const ProfileTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final walletState = ref.watch(walletStateProvider);
    final user = authState.currentUser;
    final theme = Theme.of(context);

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            stretch: true,
            backgroundColor: theme.scaffoldBackgroundColor,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              background: Stack(
                alignment: Alignment.center,
                children: [
                  // Subtle Background Glow
                  Positioned(
                    top: -100,
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            theme.colorScheme.primary.withOpacity(0.15),
                            theme.colorScheme.primary.withOpacity(0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 60),
                      Hero(
                        tag: 'profile_pic',
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            context.push('/profile-icons');
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: theme.colorScheme.primary
                                      .withOpacity(0.5),
                                  width: 2),
                            ),
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: theme.colorScheme.surface,
                              backgroundImage: user.profileImageUrl != null
                                  ? NetworkImage(user.profileImageUrl!)
                                  : null,
                              child: user.profileImageUrl == null
                                  ? Text(
                                      user.firstName.isNotEmpty
                                          ? user.firstName[0].toUpperCase()
                                          : '?',
                                      style: theme.textTheme.displaySmall
                                          ?.copyWith(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.fullName,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        '@${user.username}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (user.bio != null && user.bio!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Text(
                            user.bio!,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade600,
                              fontStyle: FontStyle.italic,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildBadge(
                              theme,
                              user.isPremiumUser ? "PREMIUM" : "FREE",
                              user.isPremiumUser
                                  ? theme.colorScheme.primary
                                  : Colors.grey),
                          const SizedBox(width: 8),
                          _buildBadge(theme, "SINCE ${user.createdAt.year}",
                              theme.colorScheme.secondary),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  // Personal Identity Overview
                  _buildIdentityOverview(context, user),
                  const SizedBox(height: 24),

                  // Quick Wallet Stats
                  _buildWalletSummary(context, walletState),
                  const SizedBox(height: 32),

                  _buildSection(context, 'Account Management', [
                    _buildTile(
                        context,
                        Icons.person_outline_rounded,
                        'Personal Information',
                        'Name, DOB, Contact, Address',
                        () => context.push('/personal-info')),
                    _buildTile(
                        context,
                        Icons.badge_outlined,
                        'Professional Profile',
                        'Occupation, Nationality, Public Bio',
                        () => context.push('/professional-profile')),
                    _buildTile(
                        context,
                        Icons.account_balance_wallet_outlined,
                        'Payment Methods',
                        'Cards, Bank Accounts',
                        () => context.push('/connect-wallet')),
                  ]),

                  const SizedBox(height: 24),

                  _buildSection(context, 'Security & Freedom', [
                    _buildTile(
                        context,
                        Icons.shield_outlined,
                        'Security Settings',
                        'Biometrics, PIN, Password',
                        () => context.push('/security-settings')),
                    _buildTile(
                        context,
                        Icons.privacy_tip_outlined,
                        'Privacy & Controls',
                        'Visibility, Data, Sharing',
                        () => context.push('/privacy-controls')),
                  ]),

                  const SizedBox(height: 24),

                  _buildSection(context, 'App Experience', [
                    _buildTile(
                        context,
                        Icons.palette_outlined,
                        'Appearance',
                        'Dark Mode, Accents',
                        () => context.push('/theme-settings')),
                    _buildTile(context, Icons.notifications_none_rounded,
                        'Notifications', 'Alerts, Receipts', () {}),
                  ]),

                  const SizedBox(height: 32),

                  // Sign Out
                  PrimaryButton(
                    onPressed: () => _showLogoutDialog(context, ref),
                    label: 'Logout',
                    backgroundColor: theme.colorScheme.error.withOpacity(0.1),
                    textColor: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Version 1.2.4 (Build 4022)',
                    style:
                        theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletSummary(BuildContext context, walletState) {
    final theme = Theme.of(context);
    final balance = walletState.wallet?.balance ?? 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Total Balance",
                  style: theme.textTheme.labelMedium
                      ?.copyWith(color: Colors.grey)),
              const SizedBox(height: 4),
              Consumer(
                builder: (context, ref, child) {
                  final currencyNotifier = ref.watch(currencyProvider.notifier);
                  return Text(
                    currencyNotifier.formatAmount(balance),
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  );
                },
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
      BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildTile(BuildContext context, IconData icon, String title,
      String subtitle, VoidCallback onTap) {
    final theme = Theme.of(context);
    return ListTile(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
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
      trailing:
          const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to exit?'),
        actions: [
          TextButton(onPressed: () => context.pop(), child: const Text('Stay')),
          TextButton(
            onPressed: () {
              context.pop();
              ref.read(authNotifierProvider.notifier).logout();
              context.go('/login');
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(ThemeData theme, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildIdentityOverview(BuildContext context, user) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          _buildIdentityRow(
              context, Icons.email_outlined, 'Email', user.email.value),
          const Divider(height: 32),
          _buildIdentityRow(context, Icons.phone_android_outlined, 'Phone',
              user.phoneNumber?.value ?? 'Not set'),
          const Divider(height: 32),
          _buildIdentityRow(context, Icons.work_outline_rounded, 'Occupation',
              user.occupation ?? 'Not set'),
          const Divider(height: 32),
          _buildIdentityRow(context, Icons.location_on_outlined, 'Residence',
              user.address ?? 'Not set'),
        ],
      ),
    );
  }

  Widget _buildIdentityRow(
      BuildContext context, IconData icon, String label, String value) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.primary.withOpacity(0.6)),
        const SizedBox(width: 12),
        Text(label,
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey)),
        const Spacer(),
        Text(value,
            style: theme.textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
