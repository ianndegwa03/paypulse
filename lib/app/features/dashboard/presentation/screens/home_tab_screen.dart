import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paypulse/app/features/auth/presentation/state/auth_notifier.dart';
import 'package:paypulse/app/features/wallet/presentation/state/wallet_providers.dart';

import 'package:go_router/go_router.dart';
import 'package:paypulse/app/features/wallet/presentation/widgets/pay_pulse_card.dart';
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
    // Ensure wallet data is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(walletStateProvider).wallet == null) {
        ref
            .read(walletStateProvider.notifier)
            .loadWallet('userId'); // TODO: Use real user ID
      }
    });
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
              // Header
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    backgroundImage: user?.profileImageUrl != null
                        ? NetworkImage(user!.profileImageUrl!)
                        : null,
                    child: user?.profileImageUrl == null
                        ? Text(
                            (user?.firstName.isNotEmpty ?? false)
                                ? user!.firstName[0].toUpperCase()
                                : 'U',
                            style: TextStyle(
                              color: theme.colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getGreeting(),
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        user?.firstName ?? "User",
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => HapticFeedback.lightImpact(),
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest
                            .withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child:
                          const Icon(Icons.qr_code_scanner_rounded, size: 20),
                    ),
                  ),
                  IconButton(
                    onPressed: () => HapticFeedback.lightImpact(),
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest
                            .withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.notifications_none_rounded,
                          size: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Search Bar Placeholder
              GestureDetector(
                onTap: () => HapticFeedback.selectionClick(),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest
                        .withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: theme.colorScheme.outline.withOpacity(0.05)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search_rounded,
                          color: theme.colorScheme.onSurfaceVariant, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        "Search transactions, bills...",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // PayPulse Interactive Card (Replaces static banner)
              if (walletState.wallet != null)
                PayPulseCard(
                  balance: walletState.wallet!.balance,
                  cardHolderName: user?.fullName ?? "Card Holder",
                  cardNumber: walletState.wallet!.cardNumber,
                  expiryDate: walletState.wallet!.expiryDate,
                  isFrozen: walletState.wallet!.isFrozen,
                )
              else
                const Center(child: CircularProgressIndicator()),

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
                      Colors.orange, () {}),
                  _homeAction(context, Icons.receipt_rounded, "Bills",
                      Colors.green, () {}),
                  _homeAction(context, Icons.grid_view_rounded, "More",
                      Colors.blueGrey, () {}),
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
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    return 'Good Evening,';
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
}
