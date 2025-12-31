import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:paypulse/app/features/auth/presentation/state/auth_notifier.dart';
import 'package:paypulse/app/features/wallet/presentation/state/wallet_providers.dart';
import 'package:paypulse/core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:paypulse/app/features/dashboard/presentation/widgets/spending_chart.dart';
import 'package:paypulse/app/features/contacts/presentation/state/contacts_provider.dart';
import 'package:paypulse/core/widgets/loading/skeleton_loader.dart';
import 'package:paypulse/app/features/dashboard/presentation/widgets/navigation_overlay.dart';
import 'package:paypulse/app/features/pro/presentation/state/pro_providers.dart';
import 'package:paypulse/app/features/analytics/presentation/state/analytics_provider.dart';

class HomeTabScreen extends ConsumerStatefulWidget {
  const HomeTabScreen({super.key});

  @override
  ConsumerState<HomeTabScreen> createState() => _HomeTabScreenState();
}

class _HomeTabScreenState extends ConsumerState<HomeTabScreen> {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.currentUser;
    final theme = Theme.of(context);
    final walletState = ref.watch(walletStateProvider);
    final isProMode = ref.watch(proModeProvider).valueOrNull ?? false;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
        ),
        child: SafeArea(
          bottom: false,
          child: RefreshIndicator(
            onRefresh: () async {
              if (user != null) {
                ref.read(walletStateProvider.notifier).loadWallet(user.id);
              }
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  sliver: SliverToBoxAdapter(
                    child: _buildHeader(context, user, theme, isProMode),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),
                        if (isProMode)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildProDashboard(context, theme),
                              const SizedBox(height: 40),
                              _sectionHeader(theme, "Quick Actions"),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  _buildQuickAction(
                                      context,
                                      Icons.receipt_long,
                                      "New Invoice",
                                      () => context.push('/invoice-generator'),
                                      theme),
                                  _buildQuickAction(
                                      context,
                                      Icons.analytics_outlined,
                                      "Analytics",
                                      () => context.push('/analytics'),
                                      theme),
                                ],
                              ),
                            ],
                          ).animate().fadeIn(duration: 600.ms).slideY(
                              begin: 0.2, end: 0, curve: Curves.easeOutBack)
                        else if (walletState.wallet != null)
                          (walletState.wallet!.linkedCards.isEmpty
                                  ? _buildLinkCardHero(context, theme)
                                  : _buildBalanceCard(
                                      context, walletState, user, theme))
                              .animate()
                              .fadeIn(duration: 600.ms)
                              .slideY(
                                  begin: 0.2, end: 0, curve: Curves.easeOutBack)
                        else if (walletState.isLoading)
                          const SkeletonLoader(
                              height: 200, width: double.infinity)
                        else
                          _buildEmptyWalletState(context, theme),

                        const SizedBox(height: 40),
                        _sectionHeader(theme, "Send Again",
                            onAction: () => context.push('/contacts')),
                        const SizedBox(height: 16),
                        _buildRecentContacts(context, theme)
                            .animate()
                            .fadeIn(delay: 200.ms),

                        const SizedBox(height: 40),
                        _sectionHeader(theme, "Social Finance"),
                        const SizedBox(height: 16),
                        _buildSocialFinanceCards(context, theme)
                            .animate()
                            .fadeIn(delay: 300.ms),

                        const SizedBox(height: 40),
                        _sectionHeader(theme, "Spending Analysis"),
                        const SizedBox(height: 16),
                        _buildSpendingOverview(context, theme, walletState)
                            .animate()
                            .fadeIn(delay: 400.ms),

                        const SizedBox(height: 120), // Padding for FloatingDock
                      ],
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

  Widget _sectionHeader(ThemeData theme, String title,
      {VoidCallback? onAction}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        if (onAction != null)
          TextButton(
            onPressed: onAction,
            child: const Text("View All"),
          ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, dynamic user, ThemeData theme,
      [bool isProMode = false]) {
    final displayName = user?.firstName ?? user?.username ?? "User";
    final proProfile = ref.watch(proProfileProvider).valueOrNull;

    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.menu_rounded, size: 28),
          onPressed: () => _showMenu(context),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isProMode ? "Pro Dashboard" : _getGreeting(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isProMode)
                Text(
                  proProfile?.businessName ?? "Business Owner",
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w900, fontSize: 20),
                )
              else
                Text(
                  displayName,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                  ),
                ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.qr_code_scanner_rounded),
          onPressed: () => context.push('/scan'),
        ),
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_none_rounded),
              onPressed: () => context.push('/notifications'),
            ),
            Positioned(
              right: 12,
              top: 12,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: () => context.push('/profile'),
          child: Hero(
            tag: 'profile_avatar',
            child: CircleAvatar(
              radius: 20,
              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
              backgroundImage: user?.profileImageUrl != null &&
                      user!.profileImageUrl!.isNotEmpty
                  ? NetworkImage(user!.profileImageUrl!)
                  : null,
              child: user?.profileImageUrl == null ||
                      user!.profileImageUrl!.isEmpty
                  ? Text(
                      displayName.isNotEmpty
                          ? displayName[0].toUpperCase()
                          : 'U',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  void _showMenu(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Menu",
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) => const NavigationOverlay(),
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(opacity: anim1, child: child);
      },
    );
  }

  Widget _buildBalanceCard(BuildContext context, dynamic walletState,
      dynamic user, ThemeData theme) {
    final analyticsState = ref.watch(analyticsProvider);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: AppColors.premiumGradient,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "NET BALANCE",
                style: TextStyle(
                    color: Colors.white60,
                    fontSize: 10,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w900),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20)),
                child: const Row(
                  children: [
                    CircleAvatar(
                        radius: 3, backgroundColor: Colors.greenAccent),
                    SizedBox(width: 6),
                    Text("Live",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            "\$${walletState.wallet?.balance.toStringAsFixed(2) ?? '0.00'}",
            style: const TextStyle(
                color: Colors.white,
                fontSize: 44,
                fontWeight: FontWeight.w900,
                letterSpacing: -2),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              _balanceStat(
                  "Income",
                  "+\$${analyticsState.totalIncome.toStringAsFixed(0)}",
                  Colors.greenAccent),
              const SizedBox(width: 32),
              _balanceStat(
                  "Expense",
                  "-\$${analyticsState.totalExpense.toStringAsFixed(0)}",
                  Colors.orangeAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _balanceStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: Colors.white54,
                fontSize: 11,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                color: color, fontSize: 16, fontWeight: FontWeight.w900)),
      ],
    );
  }

  Widget _buildProDashboard(BuildContext context, ThemeData theme) {
    final analyticsState = ref.watch(analyticsProvider);
    final proProfile = ref.watch(proProfileProvider).valueOrNull;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.black, // Pro theme is dark
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("MONTHLY REVENUE",
                  style: TextStyle(
                      color: Colors.white54,
                      fontSize: 10,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w900)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20)),
                child: const Text("PRO",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text("\$${analyticsState.totalIncome.toStringAsFixed(2)}",
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 44,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -2)),
          const SizedBox(height: 32),
          Row(
            children: [
              _balanceStat("Pending", "N/A", Colors.amberAccent),
              const SizedBox(width: 32),
              _balanceStat("Profession", proProfile?.profession ?? "Freelancer",
                  Colors.blueAccent),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => context.push('/invoice-generator'),
              icon: const Icon(Icons.add_circle_outline, color: Colors.black),
              label: const Text("New Invoice",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildRecentContacts(BuildContext context, ThemeData theme) {
    return SizedBox(
      height: 100,
      child: ref.watch(contactsProvider).when(
            data: (contacts) {
              if (contacts.isEmpty) return const SizedBox.shrink();
              return ListView.separated(
                padding: EdgeInsets.zero,
                scrollDirection: Axis.horizontal,
                itemCount: contacts.take(8).length,
                separatorBuilder: (_, __) => const SizedBox(width: 20),
                itemBuilder: (context, index) {
                  final contact = contacts[index];
                  return Column(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: theme.colorScheme.surface,
                        backgroundImage: contact.photo != null
                            ? MemoryImage(contact.photo!)
                            : null,
                        child: contact.photo == null
                            ? Text(contact.displayName[0],
                                style: TextStyle(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.bold))
                            : null,
                      ),
                      const SizedBox(height: 8),
                      Text(contact.displayName.split(' ').first,
                          style: theme.textTheme.labelSmall
                              ?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const SizedBox.shrink(),
          ),
    );
  }

  Widget _buildSpendingOverview(
      BuildContext context, ThemeData theme, dynamic walletState) {
    return Container(
      height: 220,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(35),
        boxShadow: AppColors.softShadow,
      ),
      child: walletState.transactions.isEmpty
          ? const Center(
              child: Text("Start spending to see pulses",
                  style: TextStyle(color: Colors.grey)))
          : SpendingChart(transactions: walletState.transactions),
    );
  }

  Widget _buildEmptyWalletState(BuildContext context, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(35),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(Icons.auto_awesome_rounded,
              size: 48, color: theme.colorScheme.primary),
          const SizedBox(height: 24),
          const Text("Financial Pulse Not Detected",
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
          const SizedBox(height: 8),
          const Text("Initialize your wallet to begin.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => context.push('/connect-wallet'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text("Wake Up Wallet"),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkCardHero(BuildContext context, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(35),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.credit_card_off_rounded,
              size: 48, color: theme.colorScheme.primary),
          const SizedBox(height: 24),
          Text(
            "No Cards Integrated",
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Link your bank or credit card to unlock the full potential of PayPulse.",
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.push('/link-card'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                elevation: 0,
              ),
              child: const Text("Integrate Card",
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialFinanceCards(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => context.push('/split-bill'),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: Colors.purpleAccent.withOpacity(0.1),
                        shape: BoxShape.circle),
                    child: const Icon(Icons.receipt_long_rounded,
                        color: Colors.purpleAccent),
                  ),
                  const SizedBox(height: 16),
                  Text("Bill Crusher",
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text("Split & Settle",
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: Colors.grey)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: GestureDetector(
            onTap: () {
              context.push('/money-circle');
            },
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: Colors.tealAccent.withValues(alpha: 0.1),
                        shape: BoxShape.circle),
                    child: const Icon(Icons.groups_rounded,
                        color: Colors.tealAccent),
                  ),
                  const SizedBox(height: 16),
                  Text("Money Circle",
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text("Group Savings",
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: Colors.grey)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAction(BuildContext context, IconData icon, String label,
      VoidCallback onTap, ThemeData theme) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: theme.colorScheme.primary),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Rise & Shine';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }
}
