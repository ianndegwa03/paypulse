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

    // Calculate total balance in selected currency
    double totalBalance = 0.0;
    if (wallet != null) {
      wallet.balances.forEach((code, amount) {
        final fromCurrency = CurrencyType.values
            .firstWhere((e) => e.name == code, orElse: () => CurrencyType.USD);
        final amountInSelected = currencyNotifier.convert(
            amount, fromCurrency, currencyState.selectedCurrency);
        totalBalance += amountInSelected;
      });
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
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
                        _buildThemedBalanceHero(
                                context,
                                totalBalance,
                                currencyNotifier,
                                currencyState.selectedCurrency)
                            .animate()
                            .scale(duration: 600.ms, curve: Curves.easeOutBack),
                        const SizedBox(height: PulseDesign.xl),
                        _buildThemedQuickActions(context),
                        const SizedBox(height: PulseDesign.xxl),
                        _buildSectionTitle(context, "Currency Pockets",
                            Icons.account_balance_wallet_rounded,
                            onAction: () => context.push('/currency-trends')),
                        const SizedBox(height: PulseDesign.m),
                        _buildPocketsRail(context, wallet?.balances ?? {},
                            currencyNotifier, currencyState, walletState),
                        const SizedBox(height: PulseDesign.xl),
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
                        _buildThemedTransactionList(context, transactions,
                            currencyNotifier, currencyState),
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
                        letterSpacing: 2)),
                Text("Universal Wallet",
                    style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.5,
                        fontSize: 28)),
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
                ),
                child: Row(
                  children: [
                    Text(metadata.symbol,
                        style: const TextStyle(
                            color: PulseDesign.primary,
                            fontWeight: FontWeight.w900)),
                    const SizedBox(width: 8),
                    Text(currencyState.selectedCurrency.name,
                        style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w900, fontSize: 11)),
                    const Icon(Icons.keyboard_arrow_down_rounded, size: 16),
                  ],
                ),
              ),
            ),
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
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(30))),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: theme.dividerColor,
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            Text("SET BASE CURRENCY",
                style: theme.textTheme.labelSmall?.copyWith(
                    color: PulseDesign.primary,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2)),
            const SizedBox(height: 16),
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
      height: 200,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          colors: isDark
              ? [PulseDesign.bgDarkCard, PulseDesign.bgDark]
              : [PulseDesign.primary, PulseDesign.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
              color: PulseDesign.primary.withOpacity(0.25),
              blurRadius: 35,
              offset: const Offset(0, 15))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("TOTAL PORTFOLIO EQUILIBRIUM",
              style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2)),
          Text("${metadata.symbol}${balance.toStringAsFixed(2)}",
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -2)),
          Row(
            children: [
              _heroStat("Delta", "+4.2%", PulseDesign.success),
              const SizedBox(width: 40),
              _heroStat("Status", "SECURED", Colors.blueAccent),
            ],
          )
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
                color: color, fontWeight: FontWeight.w900, fontSize: 16)),
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
            onTap: () => context.push('/auth-selection')),
        _themedActionBtn(
            context, "Split", Icons.group_add_rounded, PulseDesign.warning,
            onTap: () => context.push('/split-bill')),
        _themedActionBtn(context, "Bank", Icons.hub_rounded, Colors.teal,
            onTap: () => context.push('/connect-wallet')),
      ],
    );
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
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: accentColor.withOpacity(0.1)),
            ),
            child: Icon(icon, color: accentColor, size: 26),
          ),
          const SizedBox(height: 8),
          Text(label,
              style:
                  const TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon,
      {VoidCallback? onAction}) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: PulseDesign.primary),
        const SizedBox(width: 8),
        Text(title.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
                color: theme.colorScheme.onSurface.withOpacity(0.6))),
        const Spacer(),
        if (onAction != null)
          IconButton(
              onPressed: onAction,
              icon: const Icon(Icons.chevron_right_rounded, size: 20))
        else
          const Icon(Icons.chevron_right_rounded, size: 20, color: Colors.grey),
      ],
    );
  }

  Widget _buildPocketsRail(
      BuildContext context,
      Map<String, double> balances,
      CurrencyNotifier currencyNotifier,
      CurrencyState currencyState,
      WalletState walletState) {
    if (balances.isEmpty) return const SizedBox.shrink();
    final sortedKeys = balances.keys.toList();
    return SizedBox(
      height: 120,
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
          return Container(
            width: 130,
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Theme.of(context).cardColor.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: Theme.of(context).dividerColor.withOpacity(0.1))),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(meta.flag, style: const TextStyle(fontSize: 16)),
              const Spacer(),
              Text('${meta.symbol}${amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w900, fontSize: 16)),
              Text(code,
                  style: const TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold)),
            ]),
          );
        },
      ),
    );
  }

  Widget _buildCardsRail(BuildContext context, List<dynamic> cards) {
    if (cards.isEmpty)
      return _emptyRailState(context, "Issue Virtual Card",
          () => context.push('/create-ghost-card'));
    return SizedBox(
        height: 180,
        child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: cards.length,
            itemBuilder: (context, index) => Container(
                width: 280,
                margin: const EdgeInsets.only(right: 16),
                child: HolographicCard(
                    child:
                        VirtualCardWidget(card: cards[index], onTap: () {})))));
  }

  Widget _buildVaultsRail(BuildContext context, List<dynamic> vaults) {
    if (vaults.isEmpty)
      return _emptyRailState(context, "Initialize Vault", () {});
    return SizedBox(
        height: 160,
        child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: vaults.length,
            itemBuilder: (context, index) => Container(
                margin: const EdgeInsets.only(right: 16),
                child: VaultCard(vault: vaults[index], onTap: () {}))));
  }

  Widget _emptyRailState(
      BuildContext context, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: Theme.of(context).cardColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: Theme.of(context).dividerColor.withOpacity(0.1),
                  style: BorderStyle.solid)),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.add_circle_outline_rounded,
                size: 20, color: PulseDesign.primary),
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.grey)),
          ])),
    );
  }

  Widget _buildThemedTransactionList(
      BuildContext context,
      List<Transaction> transactions,
      CurrencyNotifier currencyNotifier,
      CurrencyState currencyState) {
    if (transactions.isEmpty)
      return const Center(
          child: Text("No transactions in ledger",
              style: TextStyle(color: Colors.grey, fontSize: 12)));
    return Column(
        children: transactions
            .map((tx) =>
                _themedTxTile(context, tx, currencyNotifier, currencyState))
            .toList());
  }

  Widget _themedTxTile(BuildContext context, Transaction tx,
      CurrencyNotifier currencyNotifier, CurrencyState currencyState) {
    final theme = Theme.of(context);
    final isDebit = tx.type == TransactionType.debit;
    final fromCurrency = CurrencyType.values.firstWhere(
        (e) => e.name == tx.currencyCode,
        orElse: () => CurrencyType.USD);
    final amountInSelected = currencyNotifier.convert(
        tx.amount, fromCurrency, currencyState.selectedCurrency);
    final metadata = getCurrencyMetadata(currencyState.selectedCurrency);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: theme.cardColor.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20)),
      child: Row(children: [
        Icon(isDebit ? Icons.arrow_outward_rounded : Icons.south_west_rounded,
            color: isDebit ? PulseDesign.warning : PulseDesign.primary,
            size: 20),
        const SizedBox(width: 14),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(tx.description,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          Text(DateFormat('MMM dd, HH:mm').format(tx.date),
              style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ])),
        Text(
            "${isDebit ? '-' : '+'}${metadata.symbol}${amountInSelected.toStringAsFixed(2)}",
            style: TextStyle(
                fontWeight: FontWeight.w900,
                color: isDebit
                    ? theme.colorScheme.onSurface
                    : PulseDesign.primary)),
      ]),
    );
  }
}
