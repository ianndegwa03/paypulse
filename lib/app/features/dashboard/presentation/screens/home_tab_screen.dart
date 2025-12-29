import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paypulse/app/features/auth/presentation/state/auth_notifier.dart';
import 'package:paypulse/app/features/wallet/presentation/state/wallet_providers.dart';
import 'package:paypulse/core/theme/app_colors.dart';

import 'package:go_router/go_router.dart';
import 'package:paypulse/app/features/dashboard/presentation/widgets/spending_chart.dart';
import 'package:paypulse/app/features/contacts/presentation/state/contacts_provider.dart';
import 'package:paypulse/core/widgets/loading/skeleton_loader.dart';

class HomeTabScreen extends ConsumerStatefulWidget {
  const HomeTabScreen({super.key});

  @override
  ConsumerState<HomeTabScreen> createState() => _HomeTabScreenState();
}

class _HomeTabScreenState extends ConsumerState<HomeTabScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.currentUser;
    final theme = Theme.of(context);
    final walletState = ref.watch(walletStateProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Interactive Header
              _buildInteractiveHeader(context, user, theme),
              const SizedBox(height: 24),

              // Search Bar - Glassmorphic
              GestureDetector(
                onTap: () => HapticFeedback.selectionClick(),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search_rounded,
                          color: Colors.white24, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        "Search assets, friends...",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white24,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.tune_rounded, color: Colors.white12, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // PayPulse Interactive Card
              if (walletState.wallet != null)
                _buildModernCard(context, walletState, user)
              else if (walletState.isLoading)
                const Center(child: CircularProgressIndicator())
              else
                _buildNoCardState(context),

              const SizedBox(height: 32),

              // Interactive Financial Health Score (Soft-sell for Premium)
              _buildPulseScoreCard(context, user),

              if (user?.isPremiumUser ?? false) ...[
                const SizedBox(height: 24),
                _buildAIInsightCard(context),
              ],

              const SizedBox(height: 32),

              // Quick Actions
              _buildSectionTitle(context, "Quick Actions"),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _homeAction(
                      context,
                      Icons.send_rounded,
                      "Send",
                      theme.colorScheme.primary,
                      () => context.push('/send-money')),
                  _homeAction(context, Icons.account_balance_rounded, "Bank",
                      Colors.orange, () => context.push('/connect-wallet')),
                  _homeAction(context, Icons.splitscreen_rounded, "Split",
                      Colors.purple, () => context.push('/split-bill')),
                  _homeAction(context, Icons.grid_view_rounded, "More",
                      Colors.blueGrey, () => _showMoreActions(context)),
                ],
              ),

              const SizedBox(height: 32),

              // Send Again section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Send Again",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push('/contacts'),
                    child: const Text("See All"),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 100,
                child: ref.watch(contactsProvider).when(
                      data: (contacts) {
                        if (contacts.isEmpty) {
                          return Center(
                            child: Text(
                              "No contacts found",
                              style: theme.textTheme.bodySmall
                                  ?.copyWith(color: Colors.grey),
                            ),
                          );
                        }
                        // Focus on contacts with photos first if possible, or just first few
                        final displayContacts = contacts.take(8).toList();
                        return ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: displayContacts.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(width: 16),
                          itemBuilder: (context, index) {
                            final contact = displayContacts[index];
                            final name = contact.displayName;
                            final photo = contact.photo;
                            return GestureDetector(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                // Navigate to send money with this contact
                                context.push('/send-money', extra: contact);
                              },
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: theme.colorScheme.primary
                                              .withOpacity(0.1)),
                                    ),
                                    child: CircleAvatar(
                                      radius: 28,
                                      backgroundColor: theme.colorScheme.primary
                                          .withOpacity(0.1),
                                      backgroundImage: photo != null
                                          ? MemoryImage(photo)
                                          : null,
                                      child: photo == null
                                          ? Text(
                                              name.isNotEmpty
                                                  ? name[0].toUpperCase()
                                                  : '?',
                                              style: TextStyle(
                                                  color:
                                                      theme.colorScheme.primary,
                                                  fontWeight: FontWeight.bold),
                                            )
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  SizedBox(
                                    width: 60,
                                    child: Text(
                                      name.split(' ').first,
                                      style: theme.textTheme.labelSmall,
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      loading: () => ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: 5,
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 16),
                        itemBuilder: (context, index) => const Column(
                          children: [
                            SkeletonLoader(
                                width: 56,
                                height: 56,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(28))),
                            SizedBox(height: 8),
                            SkeletonLoader(width: 40, height: 10),
                          ],
                        ),
                      ),
                      error: (e, r) => const Center(
                          child: Icon(Icons.error_outline, color: Colors.grey)),
                    ),
              ),

              const SizedBox(height: 32),

              // Insights / Chart
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Overview",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "This Week",
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                height: 240,
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    )
                  ],
                  border: Border.all(
                      color: theme.colorScheme.outline.withOpacity(0.05)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Spending Trend",
                            style: theme.textTheme.labelMedium
                                ?.copyWith(color: Colors.grey)),
                        Icon(Icons.show_chart,
                            color: theme.colorScheme.primary, size: 20),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                        child: SpendingChart(
                            transactions: walletState.transactions)),
                  ],
                ),
              ),
              const SizedBox(height: 80), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _getGreetingEmoji() {
    final hour = DateTime.now().hour;
    if (hour < 12) return '☀️';
    if (hour < 17) return '🌤️';
    return '🌙';
  }

  Widget _buildInteractiveHeader(
      BuildContext context, dynamic user, ThemeData theme) {
    // Get display name: Try firstName, then username, then "User"
    String displayName = "User";
    if (user?.firstName != null && user!.firstName!.isNotEmpty) {
      displayName = user!.firstName!;
    } else if (user?.username != null && user!.username!.isNotEmpty) {
      displayName = user!.username!;
      // Capitalize first letter of username
      if (displayName.isNotEmpty) {
        displayName = displayName[0].toUpperCase() + displayName.substring(1);
      }
    }

    return Row(
      children: [
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            context.push('/profile');
          },
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: 24,
              backgroundColor: theme.colorScheme.primaryContainer,
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
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    )
                  : null,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      '${_getGreeting()}, $displayName! ${_getGreetingEmoji()}'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _getGreeting(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade400,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(_getGreetingEmoji(),
                        style: const TextStyle(fontSize: 14)),
                  ],
                ),
                Text(
                  displayName,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
        IconButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            context.push('/qr-scan');
          },
          icon: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.qr_code_scanner_rounded, size: 20),
          ),
        ),
        IconButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            // TODO: Navigate to notifications
          },
          icon: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_none_rounded, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _homeAction(BuildContext context, IconData icon, String label,
      Color color, VoidCallback onTap) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Column(
        children: [
          Container(
            height: 64,
            width: 64,
            decoration: BoxDecoration(
              color: color.withOpacity(isDark ? 0.15 : 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
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
        gradient: AppColors.premiumGradient,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
            color: Colors.white.withOpacity(0.08)), // Subtle contrast border
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
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
            padding: const EdgeInsets.all(28.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Current Balance",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const Icon(Icons.nfc_rounded, color: Colors.white38),
                  ],
                ),
                Text(
                  "\$${walletState.wallet?.balance.toStringAsFixed(2) ?? '0.00'}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.5,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      user?.fullName.toUpperCase() ?? "VALUED HOLDER",
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                        letterSpacing: 2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      "PAYPULSE PREMIUM",
                      style: TextStyle(
                        color: Colors.white30,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPulseScoreCard(BuildContext context, dynamic user) {
    final theme = Theme.of(context);
    final isPremium = user?.isPremiumUser ?? false;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.bolt_rounded, color: Colors.green),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Pulse Score",
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      isPremium
                          ? "Your financial health is optimal"
                          : "84/100 · Strong Health",
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              if (!isPremium)
                TextButton(
                  onPressed: () => _showPulseDetails(context),
                  child: const Text("Details"),
                ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: 0.84,
              minHeight: 8,
              backgroundColor: Colors.grey.withOpacity(0.1),
              valueColor: const AlwaysStoppedAnimation(Colors.green),
            ),
          ),
        ],
      ),
    );
  }

  void _showPulseDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 32),
            const Icon(Icons.analytics_rounded, size: 64, color: Colors.blue),
            const SizedBox(height: 24),
            const Text(
              "Financial Analysis",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              "Get deep insights into your spending habits and optimized savings recommendations.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, height: 1.5),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text("Unlock Full Insights"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAIInsightCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade900.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.deepPurple.shade400.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade400.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.auto_awesome,
                    color: Colors.deepPurpleAccent, size: 18),
              ),
              const SizedBox(width: 12),
              const Text("AI Spending Insight",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurpleAccent)),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            "You spent 12% more on Dining this week. We recommend setting a budget of \$200 for next week to save \$45.",
            style: TextStyle(fontSize: 13, height: 1.4, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  void _showMoreActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("More Features",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.ac_unit_rounded, color: Colors.blue),
              title: const Text("Freeze Physical Card"),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.security_rounded, color: Colors.green),
              title: const Text("View Security Settings"),
              onTap: () {
                Navigator.pop(context);
                context.push('/security-settings');
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.help_outline_rounded, color: Colors.orange),
              title: const Text("Support Center"),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoCardState(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        context.push('/connect-wallet');
      },
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: theme.colorScheme.primary.withOpacity(0.2),
            width: 2,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add_card_rounded,
                size: 40,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Link Your First Card",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Connect a bank or card to get started",
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
