import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:paypulse/app/features/wallet/presentation/state/wallet_providers.dart';
import 'package:paypulse/app/features/wallet/presentation/state/wallet_state.dart';
import 'package:paypulse/app/features/wallet/presentation/state/currency_provider.dart';
import 'package:paypulse/app/features/wallet/presentation/widgets/vault_card.dart';
import 'package:paypulse/app/features/wallet/presentation/widgets/virtual_card_widget.dart';
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

    // Calculate total balance in selected currency
    double totalBalance = 0.0;
    if (wallet != null) {
      wallet.balances.forEach((code, amount) {
        // Map code string to CurrencyType if possible, else default to USD
        final fromCurrency = CurrencyType.values
            .firstWhere((e) => e.name == code, orElse: () => CurrencyType.USD);

        // Convert amount to selected currency
        final amountInSelected = currencyNotifier.convert(
            amount, fromCurrency, currencyState.selectedCurrency);
        totalBalance += amountInSelected;
      });
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildThemedHeader(context, currencyState, currencyNotifier),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildThemedBalanceHero(context, totalBalance,
                            currencyNotifier, currencyState.selectedCurrency)
                        .animate()
                        .fadeIn(duration: 600.ms)
                        .slideY(begin: 0.2, end: 0, curve: Curves.easeOutBack),
                    const SizedBox(height: 48),
                    _buildSectionTitle(context, "Currency Pockets",
                        Icons.account_balance_wallet_rounded,
                        onAction: () => context.push('/currency-trends')),
                    const SizedBox(height: 20),
                    _buildPocketsRail(context, wallet?.balances ?? {},
                        currencyNotifier, currencyState, walletState),
                    const SizedBox(height: 20),
                    _buildSectionTitle(
                        context, "Digital Assets", Icons.credit_card_rounded),
                    const SizedBox(height: 20),
                    _buildCardsRail(context, wallet?.virtualCards ?? []),
                    const SizedBox(height: 40),
                    _buildSectionTitle(context, "Protected Vaults",
                        Icons.lock_outline_rounded),
                    const SizedBox(height: 20),
                    _buildVaultsRail(context, wallet?.vaults ?? []),
                    const SizedBox(height: 40),
                    _buildSectionTitle(
                        context, "Transaction Ledger", Icons.history_rounded),
                    const SizedBox(height: 20),
                    _buildThemedTransactionList(
                        context, transactions, currencyNotifier, currencyState),
                    const SizedBox(height: 140), // Padding for FloatingDock
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemedHeader(BuildContext context, CurrencyState currencyState,
      CurrencyNotifier currencyNotifier) {
    final theme = Theme.of(context);
    final metadata = getCurrencyMetadata(currencyState.selectedCurrency);

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("LIQUID ASSETS",
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    )),
                Text("Universal Wallet",
                    style: theme.textTheme.headlineLarge?.copyWith(
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
                    border:
                        Border.all(color: theme.dividerColor.withOpacity(0.05)),
                    boxShadow: [
                      BoxShadow(
                          color: theme.shadowColor.withOpacity(0.02),
                          blurRadius: 10)
                    ]),
                child: Row(
                  children: [
                    Text(metadata.symbol,
                        style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w900)),
                    const SizedBox(width: 8),
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
          borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
          border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
        ),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: theme.dividerColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 32),
            Text("SET BASE CURRENCY",
                style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2)),
            const SizedBox(height: 24),
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
                          ? Icon(Icons.check_circle_rounded,
                              color: theme.colorScheme.primary)
                          : null,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ))
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildThemedBalanceHero(BuildContext context, double balance,
      CurrencyNotifier currencyNotifier, CurrencyType currencyType) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final metadata = getCurrencyMetadata(currencyType);

    return Container(
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(36),
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                : [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withBlue(220)
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
                color: theme.colorScheme.primary.withOpacity(0.25),
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
            padding: const EdgeInsets.all(32),
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
                          Text(
                            "SECURE",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const SizedBox(height: 12),
                Text('${metadata.symbol}${balance.toStringAsFixed(2)}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 52,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -3)),
                const Spacer(),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12)),
                      child: const Row(
                        children: [
                          Icon(Icons.trending_up_rounded,
                              color: Colors.greenAccent, size: 16),
                          SizedBox(width: 8),
                          Text(
                            "Active",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon,
      {VoidCallback? onAction}) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Text(title.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
                color: theme.colorScheme.onSurface.withOpacity(0.6))),
        const Spacer(),
        if (onAction != null)
          IconButton(
            onPressed: onAction,
            icon: Icon(Icons.chevron_right_rounded,
                color: theme.colorScheme.onSurface.withOpacity(0.2)),
          )
        else
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
            child: VirtualCardWidget(card: cards[index], onTap: () {}),
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

  Widget _buildPocketsRail(
      BuildContext context,
      Map<String, double> balances,
      CurrencyNotifier currencyNotifier,
      CurrencyState currencyState,
      WalletState walletState) {
    if (balances.isEmpty) {
      return const SizedBox.shrink();
    }

    final selectedCurrency = currencyState.selectedCurrency;

    // Sort balances: selected currency first, then others
    final sortedKeys = balances.keys.toList()
      ..sort((a, b) {
        if (a == selectedCurrency.name) return -1;
        if (b == selectedCurrency.name) return 1;
        return a.compareTo(b);
      });

    return SizedBox(
      height: 145, // Increased height for P/L chip
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: sortedKeys.length,
        itemBuilder: (context, index) {
          final code = sortedKeys[index];
          final amount = balances[code]!;

          final type = CurrencyType.values.firstWhere((e) => e.name == code,
              orElse: () => CurrencyType.USD);
          final meta = getCurrencyMetadata(type);

          // Calculate Profit/Loss
          // We compare current rate vs cost basis
          final currentRate = currencyState.getRate(CurrencyType.USD, type);
          final basisRate = walletState.wallet?.costBasis[code] ?? currentRate;

          double plPercent = 0.0;
          if (basisRate > 0) {
            // If basis is 135 and current is 140, we gained value (more KES per USD? No, wait)
            // If we bought KES at 135 KES/USD, and now it's 130 KES/USD, the KES strengthened.
            // Our USD value increased.
            // Gain = (Amount / currentRate) - (Amount / basisRate)
            // But let's simplify for the UI: basisRate is the rate we BOUGHT at.
            // If currentRate < basisRate, KES reached a better position.
            plPercent = ((basisRate - currentRate) / basisRate) * 100;
          }

          final isGain = plPercent > 0;

          // Approximate value in selected currency for reference if different
          String? subValue;
          if (type != selectedCurrency) {
            final conv =
                currencyNotifier.convert(amount, type, selectedCurrency);
            final selectedMeta = getCurrencyMetadata(selectedCurrency);
            subValue = '≈ ${selectedMeta.symbol}${conv.toStringAsFixed(2)}';
          }

          return Container(
            width: 140,
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                  color: type == selectedCurrency
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.5)
                      : Theme.of(context).dividerColor.withOpacity(0.1),
                  width: type == selectedCurrency ? 2 : 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(meta.flag, style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 8),
                        Text(code,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                    if (type != CurrencyType.USD)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: (isGain ? Colors.green : Colors.red)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          "${isGain ? '+' : ''}${plPercent.toStringAsFixed(1)}%",
                          style: TextStyle(
                            color: isGain ? Colors.green : Colors.red,
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                  ],
                ),
                const Spacer(),
                Text('${meta.symbol}${amount.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w900, fontSize: 18),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                if (subValue != null)
                  Text(subValue,
                      style: TextStyle(
                          fontSize: 10,
                          color: Theme.of(context).disabledColor,
                          fontWeight: FontWeight.w600)),
              ],
            ),
          );
        },
      ),
    ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.1);
  }

  Widget _themedEmptyState(BuildContext context, String label, IconData icon) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon,
              color: theme.colorScheme.primary.withOpacity(0.4), size: 20),
          const SizedBox(width: 12),
          Text(label,
              style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.4),
                  fontWeight: FontWeight.w900,
                  fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildThemedTransactionList(
      BuildContext context,
      List<Transaction> transactions,
      CurrencyNotifier currencyNotifier,
      CurrencyState currencyState) {
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
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                  foregroundColor: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: transactions
          .map((tx) =>
              _themedTxTile(context, tx, currencyNotifier, currencyState))
          .toList(),
    );
  }

  Widget _themedTxTile(BuildContext context, Transaction tx,
      CurrencyNotifier currencyNotifier, CurrencyState currencyState) {
    final theme = Theme.of(context);
    final isDebit = tx.type == TransactionType.debit;

    // Convert transaction amount to selected currency
    // final currencyState = ref.read(currencyProvider); // REMOVED
    final fromCurrency = CurrencyType.values.firstWhere(
        (e) => e.name == tx.currencyCode,
        orElse: () => CurrencyType.USD);
    final amountInSelected = currencyNotifier.convert(
        tx.amount, fromCurrency, currencyState.selectedCurrency);
    final metadata = getCurrencyMetadata(currencyState.selectedCurrency);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: theme.dividerColor.withOpacity(0.03)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (isDebit ? Colors.orange : theme.colorScheme.primary)
                  .withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isDebit ? Icons.arrow_outward_rounded : Icons.south_west_rounded,
              color: isDebit ? Colors.orange : theme.colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
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
            "${isDebit ? '-' : '+'}${metadata.symbol}${amountInSelected.toStringAsFixed(2)}",
            style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: isDebit
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.primary),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.1, curve: Curves.easeOut);
  }
}
