import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:paypulse/app/features/wallet/presentation/state/wallet_providers.dart';
import 'package:paypulse/app/features/wallet/presentation/state/currency_provider.dart';
import 'package:paypulse/app/features/wallet/presentation/widgets/vault_card.dart';
import 'package:paypulse/app/features/wallet/presentation/widgets/virtual_card_widget.dart';
import 'package:paypulse/app/features/wallet/presentation/widgets/holographic_card.dart';
import 'package:paypulse/core/theme/design_system_v2.dart';
import 'package:paypulse/domain/entities/transaction_entity.dart';
import 'package:paypulse/domain/entities/enums.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';

class WalletTabScreen extends ConsumerWidget {
  const WalletTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final walletState = ref.watch(walletStateProvider);
    final currencyState = ref.watch(currencyProvider);
    final currencyNotifier = ref.read(currencyProvider.notifier);

    final wallet = walletState.wallet;
    final transactions = walletState.transactions;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Dynamic theme-aware background glows
          _buildBackgroundGlows(theme),

          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildThemedHeader(context, currencyState, currencyNotifier),
                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: PulseDesign.l),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildThemedBalanceHero(context, wallet?.balance ?? 0.0,
                                currencyNotifier)
                            .animate()
                            .scale(duration: 600.ms, curve: Curves.easeOutBack),
                        const SizedBox(height: PulseDesign.xl),
                        _buildThemedQuickActions(context),
                        const SizedBox(height: PulseDesign.xxl),
                        _buildSectionTitle(context, "Identity Cards",
                            Icons.credit_card_rounded),
                        const SizedBox(height: PulseDesign.m),
                        _buildCardsRail(context, wallet?.virtualCards ?? []),
                        const SizedBox(height: PulseDesign.xl),
                        _buildSectionTitle(
                            context, "Sovereign Vaults", Icons.savings_rounded),
                        const SizedBox(height: PulseDesign.m),
                        _buildVaultsRail(context, wallet?.vaults ?? []),
                        const SizedBox(height: PulseDesign.xl),
                        _buildSectionTitle(
                            context, "Network Ledger", Icons.history_rounded),
                        const SizedBox(height: PulseDesign.m),
                        _buildThemedTransactionList(
                            context, transactions, currencyNotifier),
                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundGlows(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return Positioned.fill(
      child: Stack(
        children: [
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: PulseDesign.primary.withOpacity(isDark ? 0.1 : 0.05),
              ),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
            child: Container(color: Colors.transparent),
          ),
        ],
      ),
    );
  }

  Widget _buildThemedHeader(BuildContext context, CurrencyState currencyState,
      CurrencyNotifier currencyNotifier) {
    final theme = Theme.of(context);
    final metadata = getCurrencyMetadata(currencyState.selectedCurrency);

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(PulseDesign.l),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("LIQUID ASSETS",
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: PulseDesign.primary,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    )),
                Text("Universal Wallet",
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1.5,
                      fontSize: 28,
                    )),
              ],
            ),
            GestureDetector(
              onTap: () => _showCurrencySelector(
                  context, currencyState, currencyNotifier),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: theme.dividerColor),
                    boxShadow: [
                      BoxShadow(
                          color: theme.shadowColor.withOpacity(0.02),
                          blurRadius: 10)
                    ]),
                child: Row(
                  children: [
                    Text(metadata.symbol,
                        style: const TextStyle(
                            color: PulseDesign.primary,
                            fontWeight: FontWeight.w900)),
                    const SizedBox(width: PulseDesign.s),
                    Text(currencyState.selectedCurrency.name,
                        style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w900, fontSize: 11)),
                    const Icon(Icons.keyboard_arrow_down_rounded, size: 16),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.2),
          ],
        ),
      ),
    );
  }

  void _showCurrencySelector(
      BuildContext context, CurrencyState state, CurrencyNotifier notifier) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(PulseDesign.radiusXl)),
          border: Border.all(color: theme.dividerColor),
        ),
        padding: const EdgeInsets.all(PulseDesign.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: theme.dividerColor,
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: PulseDesign.xl),
            Text("SET BASE CURRENCY",
                style: theme.textTheme.labelSmall?.copyWith(
                    color: PulseDesign.primary,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2)),
            const SizedBox(height: PulseDesign.l),
            ...CurrencyType.values
                .map((c) => ListTile(
                      onTap: () {
                        notifier.setCurrency(c);
                        Navigator.pop(context);
                      },
                      title: Text(c.name,
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w900)),
                      trailing: state.selectedCurrency == c
                          ? const Icon(Icons.check_circle_rounded,
                              color: PulseDesign.primary)
                          : null,
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(PulseDesign.radiusM)),
                    ))
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildThemedBalanceHero(BuildContext context, double balanceUSD,
      CurrencyNotifier currencyNotifier) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(PulseDesign.radiusXl),
          gradient: LinearGradient(
            colors: isDark
                ? [PulseDesign.bgDarkCard, PulseDesign.bgDark]
                : [PulseDesign.primary, PulseDesign.primary.withBlue(220)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
                color: PulseDesign.primary.withOpacity(0.25),
                blurRadius: 35,
                offset: const Offset(0, 15))
          ]),
      child: Stack(
        children: [
          Positioned(
            right: -40,
            bottom: -40,
            child: Icon(Icons.blur_on_rounded,
                size: 240, color: Colors.white.withOpacity(0.04)),
          ),
          Padding(
            padding: const EdgeInsets.all(PulseDesign.l),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text("TOTAL AVAILABLE EQUILIBRIUM",
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(100)),
                      child: const Row(
                        children: [
                          Icon(Icons.verified_user_rounded,
                              color: Colors.blueAccent, size: 10),
                          SizedBox(width: 4),
                          Text("SECURE",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w900)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: PulseDesign.s),
                Text(currencyNotifier.formatAmount(balanceUSD),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 52,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -3)),
                const Spacer(),
                Row(
                  children: [
                    _heroStat("Portfolio Delta", "+4.2%", PulseDesign.success),
                    const SizedBox(width: 40),
                    _heroStat(
                        "Daily Outflow",
                        currencyNotifier.formatAmount(42.50),
                        Colors.white.withOpacity(0.8)),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 10,
                fontWeight: FontWeight.w900)),
        Text(value,
            style: TextStyle(
                color: color,
                fontWeight: FontWeight.w900,
                fontSize: 16,
                letterSpacing: -0.5)),
      ],
    );
  }

  Widget _buildThemedQuickActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _themedActionBtn(
            context, "Send", Icons.send_rounded, PulseDesign.primary,
            onTap: () => context.push('/send-money')),
        _themedActionBtn(context, "Receive", Icons.qr_code_scanner_rounded,
            PulseDesign.accent,
            onTap: () => context.push('/my-qr')),
        _themedActionBtn(
            context, "Split", Icons.group_add_rounded, PulseDesign.warning,
            onTap: () => context.push('/split-bill')),
        _themedActionBtn(context, "Connect", Icons.hub_rounded, Colors.teal,
            onTap: () => context.push('/connect-wallet')),
      ],
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2);
  }

  Widget _themedActionBtn(
      BuildContext context, String label, IconData icon, Color accentColor,
      {required VoidCallback onTap}) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(PulseDesign.radiusL),
                border: Border.all(color: accentColor.withOpacity(0.1)),
                boxShadow: [
                  BoxShadow(
                      color: accentColor.withOpacity(0.08),
                      blurRadius: 15,
                      offset: const Offset(0, 8))
                ]),
            child: Icon(icon, color: accentColor, size: 28),
          ),
          const SizedBox(height: PulseDesign.s),
          Text(label,
              style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                  letterSpacing: 0.5)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: PulseDesign.primary),
        const SizedBox(width: PulseDesign.s),
        Text(title.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
                color: theme.colorScheme.onSurface.withOpacity(0.6))),
        const Spacer(),
        Icon(Icons.chevron_right_rounded,
            color: theme.colorScheme.onSurface.withOpacity(0.2)),
      ],
    );
  }

  Widget _buildCardsRail(BuildContext context, List<dynamic> cards) {
    if (cards.isEmpty) {
      return GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          context.push('/create-ghost-card');
        },
        child: _themedEmptyState(
            context, "Issue Synthetic Card", Icons.add_circle_outline_rounded),
      );
    }
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: cards.length,
        itemBuilder: (context, index) {
          return Container(
            width: 280,
            margin: const EdgeInsets.only(right: 16),
            child: HolographicCard(
              child: VirtualCardWidget(card: cards[index], onTap: () {}),
            ),
          );
        },
      ),
    ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.1);
  }

  Widget _buildVaultsRail(BuildContext context, List<dynamic> vaults) {
    if (vaults.isEmpty) {
      return GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Global Vaults coming soon')),
          );
        },
        child: _themedEmptyState(
            context, "Initialize Sovereign Vault", Icons.lock_outline_rounded),
      );
    }
    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: vaults.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(right: 16),
            child: VaultCard(vault: vaults[index], onTap: () {}),
          );
        },
      ),
    ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.1);
  }

  Widget _themedEmptyState(BuildContext context, String label, IconData icon) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(PulseDesign.radiusL),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: PulseDesign.primary.withOpacity(0.4), size: 20),
          const SizedBox(width: PulseDesign.s),
          Text(label,
              style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.4),
                  fontWeight: FontWeight.w900,
                  fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildThemedTransactionList(BuildContext context,
      List<Transaction> transactions, CurrencyNotifier currencyNotifier) {
    final theme = Theme.of(context);
    if (transactions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              Text("Zero network activity",
                  style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () => context.push('/connect-wallet'),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add Funds'),
                style: TextButton.styleFrom(
                  backgroundColor: PulseDesign.primary.withOpacity(0.1),
                  foregroundColor: PulseDesign.primary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: transactions
          .map((tx) => _themedTxTile(context, tx, currencyNotifier))
          .toList(),
    );
  }

  Widget _themedTxTile(
      BuildContext context, Transaction tx, CurrencyNotifier currencyNotifier) {
    final theme = Theme.of(context);
    final isDebit = tx.type == TransactionType.debit;

    return Container(
      margin: const EdgeInsets.only(bottom: PulseDesign.s),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(PulseDesign.radiusL),
        border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (isDebit ? PulseDesign.warning : PulseDesign.primary)
                  .withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isDebit ? Icons.arrow_outward_rounded : Icons.south_west_rounded,
              color: isDebit ? PulseDesign.warning : PulseDesign.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: PulseDesign.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.description,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w900, fontSize: 15),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(DateFormat('MMM dd • hh:mm a').format(tx.date),
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.3),
                        fontWeight: FontWeight.w900)),
              ],
            ),
          ),
          Text(
            "${isDebit ? '-' : '+'}${currencyNotifier.formatAmount(tx.amount)}",
            style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: isDebit
                    ? theme.colorScheme.onSurface
                    : PulseDesign.primary),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.1, curve: Curves.easeOut);
  }
}
