import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:paypulse/app/features/auth/presentation/state/auth_notifier.dart';
import 'package:paypulse/app/features/wallet/presentation/state/wallet_providers.dart';
import 'package:paypulse/core/theme/design_system_v2.dart';
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
    final isDark = theme.brightness == Brightness.dark;
    final walletState = ref.watch(walletStateProvider);
    final isProMode = ref.watch(proModeProvider).valueOrNull ?? false;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async {
            if (user != null) {
              ref.read(walletStateProvider.notifier).loadWallet(user.id);
            }
          },
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(PulseDesign.l),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context, user, theme, isProMode),
                      const SizedBox(height: 24),
                      _buildSearchAnchor(theme, isDark),
                      const SizedBox(height: 32),
                      if (isProMode)
                        _buildProDashboard(context, theme)
                            .animate()
                            .fadeIn(duration: 600.ms)
                            .slideY(begin: 0.1)
                      else if (walletState.wallet != null)
                        _buildModernCard(context, walletState, user)
                            .animate()
                            .fadeIn(duration: 600.ms)
                            .slideY(begin: 0.1)
                      else if (walletState.isLoading)
                        const SkeletonLoader(
                            height: 200, width: double.infinity)
                      else
                        _buildNoCardState(context),
                      const SizedBox(height: 32),
                      _buildPulseScoreCard(context, user),
                      if (user?.isPremiumUser ?? false) ...[
                        const SizedBox(height: 20),
                        _buildAIInsightCard(context),
                      ],
                      const SizedBox(height: 40),
                      _buildSectionTitle(context, "Quick Actions"),
                      const SizedBox(height: 20),
                      _buildQuickActionsRow(context, theme, isDark),
                      const SizedBox(height: 40),
                      _buildSectionTitle(context, "Send Again",
                          onAction: () => context.push('/contacts')),
                      const SizedBox(height: 16),
                      _buildRecentContacts(context, theme),
                      const SizedBox(height: 40),
                      _buildSectionTitle(context, "Spending Analysis"),
                      const SizedBox(height: 20),
                      _buildSpendingOverview(context, theme, walletState),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, dynamic user, ThemeData theme, bool isProMode) {
    final displayName = user?.firstName ?? user?.username ?? "User";

    return Row(
      children: [
        GestureDetector(
          onTap: () => _showMenu(context),
          child: CircleAvatar(
            radius: 20,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            child: Icon(Icons.menu_rounded,
                size: 20, color: theme.colorScheme.onSurface),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    isProMode ? "Pro Dashboard" : _getGreeting(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(_getGreetingEmoji(),
                      style: const TextStyle(fontSize: 12)),
                ],
              ),
              Text(
                displayName,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => context.push('/scan'),
          icon: const Icon(Icons.qr_code_scanner_rounded),
        ),
        IconButton(
          onPressed: () => context.push('/notifications'),
          icon: const Icon(Icons.notifications_none_rounded),
        ),
      ],
    );
  }

  Widget _buildSearchAnchor(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? PulseDesign.glassDark : PulseDesign.glassLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Icon(Icons.search_rounded,
              color: theme.colorScheme.onSurface.withOpacity(0.4), size: 20),
          const SizedBox(width: 12),
          Text(
            "Search transactions, contacts...",
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernCard(
      BuildContext context, dynamic walletState, dynamic user) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [PulseDesign.primary, PulseDesign.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: PulseDesign.primary.withOpacity(0.3),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Opacity(
              opacity: 0.1,
              child: Icon(Icons.blur_circular, size: 200, color: Colors.white),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Current Balance",
                        style: TextStyle(color: Colors.white70, fontSize: 14)),
                    const Icon(Icons.nfc_rounded, color: Colors.white38),
                  ],
                ),
                Text(
                  "KES ${walletState.wallet?.balance.toStringAsFixed(2) ?? '0.00'}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      user?.fullName?.toUpperCase() ?? "USER HOLDER",
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 11,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text("PAYPULSE PREMIUM",
                        style: TextStyle(
                            color: Colors.white30,
                            fontSize: 10,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProDashboard(BuildContext context, ThemeData theme) {
    final analyticsState = ref.watch(analyticsProvider);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 30,
              offset: const Offset(0, 15))
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
          Text("KES ${analyticsState.totalIncome.toStringAsFixed(2)}",
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1)),
          const SizedBox(height: 24),
          Row(
            children: [
              _proStat("Invoices", "12", Colors.blueAccent),
              const SizedBox(width: 32),
              _proStat("Clients", "8", Colors.tealAccent),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.push('/invoice-generator'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text("Create Invoice",
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  Widget _proStat(String label, String value, Color color) {
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
                color: color, fontSize: 18, fontWeight: FontWeight.w900)),
      ],
    );
  }

  Widget _buildPulseScoreCard(BuildContext context, dynamic user) {
    final theme = Theme.of(context);
    final isPremium = user?.isPremiumUser ?? false;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: PulseDesign.success.withOpacity(0.1),
                      shape: BoxShape.circle),
                  child: const Icon(Icons.bolt_rounded,
                      color: PulseDesign.success, size: 20)),
              const SizedBox(width: 14),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    const Text("Financial Pulse",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                        isPremium
                            ? "Optimal health detected"
                            : "Score: 78/100 · Strong",
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ])),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: const LinearProgressIndicator(
                  value: 0.78,
                  minHeight: 6,
                  backgroundColor: Colors.grey,
                  valueColor: AlwaysStoppedAnimation(PulseDesign.success))),
        ],
      ),
    );
  }

  Widget _buildAIInsightCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: PulseDesign.accent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: PulseDesign.accent.withOpacity(0.2))),
      child: const Row(children: [
        Icon(Icons.auto_awesome, color: PulseDesign.accent, size: 20),
        const SizedBox(width: 14),
        Expanded(
            child: Text("You saved 15% more than last week! 🎉",
                style: TextStyle(
                    color: PulseDesign.accent,
                    fontWeight: FontWeight.bold,
                    fontSize: 13))),
      ]),
    );
  }

  Widget _buildQuickActionsRow(
      BuildContext context, ThemeData theme, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _quickAction(context, Icons.send_rounded, "Send", PulseDesign.primary,
            () => context.push('/send-money'), isDark),
        _quickAction(context, Icons.account_balance_rounded, "Bank",
            PulseDesign.warning, () => context.push('/connect-wallet'), isDark),
        _quickAction(context, Icons.splitscreen_rounded, "Split",
            PulseDesign.accent, () => context.push('/split-bill'), isDark),
        _quickAction(context, Icons.grid_view_rounded, "More", Colors.grey,
            () => _showMoreActions(context), isDark),
      ],
    );
  }

  Widget _quickAction(BuildContext context, IconData icon, String label,
      Color color, VoidCallback onTap, bool isDark) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: color.withOpacity(isDark ? 0.15 : 0.1),
                borderRadius: BorderRadius.circular(20)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(label,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildRecentContacts(BuildContext context, ThemeData theme) {
    return SizedBox(
      height: 100,
      child: ref.watch(contactsProvider).when(
            data: (contacts) {
              if (contacts.isEmpty)
                return const Center(
                    child: Text("No recent contacts",
                        style: TextStyle(color: Colors.grey, fontSize: 12)));
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: contacts.take(6).length,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final contact = contacts[index];
                  return GestureDetector(
                    onTap: () => context.push('/send-money', extra: contact),
                    child: Column(children: [
                      CircleAvatar(
                          radius: 28,
                          backgroundColor:
                              theme.colorScheme.surfaceContainerHighest,
                          backgroundImage: contact.photo != null
                              ? MemoryImage(contact.photo!)
                              : null,
                          child: contact.photo == null
                              ? Text(contact.displayName[0],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold))
                              : null),
                      const SizedBox(height: 6),
                      Text(contact.displayName.split(' ').first,
                          style: const TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w600)),
                    ]),
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
          color: theme.cardColor.withOpacity(0.5),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: theme.dividerColor.withOpacity(0.05))),
      child: walletState.transactions.isEmpty
          ? const Center(
              child: Text("No transactions yet",
                  style: TextStyle(color: Colors.grey)))
          : SpendingChart(transactions: walletState.transactions),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title,
      {VoidCallback? onAction}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5)),
        if (onAction != null)
          TextButton(onPressed: onAction, child: const Text("See All")),
      ],
    );
  }

  Widget _buildNoCardState(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/connect-wallet'),
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
                color: PulseDesign.primary.withOpacity(0.2),
                width: 2,
                style: BorderStyle.solid)),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.add_card_rounded,
              size: 40, color: PulseDesign.primary.withOpacity(0.5)),
          const SizedBox(height: 12),
          const Text("Link a payment method",
              style: TextStyle(fontWeight: FontWeight.bold)),
        ]),
      ),
    );
  }

  void _showMenu(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Menu",
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) => const NavigationOverlay(),
      transitionBuilder: (context, anim1, anim2, child) =>
          FadeTransition(opacity: anim1, child: child),
    );
  }

  void _showMoreActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text("More Actions",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ListTile(
              leading: const Icon(Icons.qr_code_2_rounded),
              title: const Text("My QR Code"),
              onTap: () => Navigator.pop(context)),
          ListTile(
              leading: const Icon(Icons.security_rounded),
              title: const Text("Security"),
              onTap: () {
                Navigator.pop(context);
                context.push('/security-settings');
              }),
          ListTile(
              leading: const Icon(Icons.help_outline_rounded),
              title: const Text("Support"),
              onTap: () => Navigator.pop(context)),
        ]),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Rise & Shine';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _getGreetingEmoji() {
    final hour = DateTime.now().hour;
    if (hour < 12) return '☀️';
    if (hour < 17) return '🌤️';
    return '🌙';
  }
}
