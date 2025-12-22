import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:paypulse/app/features/wallet/presentation/state/wallet_providers.dart';
import 'package:paypulse/app/features/wallet/presentation/widgets/pay_pulse_card.dart';
import 'package:paypulse/domain/entities/transaction_entity.dart';
import 'package:paypulse/domain/entities/enums.dart';
import 'package:paypulse/app/features/auth/presentation/state/auth_notifier.dart';

class WalletOverviewScreen extends ConsumerWidget {
  const WalletOverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final walletState = ref.watch(walletStateProvider);
    final user = ref.watch(authNotifierProvider).currentUser;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('My Assets',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle),
              child: Icon(Icons.tune_rounded,
                  size: 18, color: theme.colorScheme.primary),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: walletState.isLoading && walletState.wallet == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async => ref.invalidate(walletStateProvider),
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.all(20),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        if (walletState.wallet != null) ...[
                          PayPulseCard(
                            balance: walletState.wallet!.balance,
                            cardHolderName: user?.fullName ?? "Member",
                            cardNumber: walletState.wallet!.cardNumber,
                            expiryDate: walletState.wallet!.expiryDate,
                            isFrozen: walletState.wallet!.isFrozen,
                          ),
                          const SizedBox(height: 24),
                          _buildQuickActions(context),
                        ],

                        const SizedBox(height: 32),
                        _buildSectionTitle(context, "Connected Banks"),
                        const SizedBox(height: 16),
                        _buildBankCarousel(context),

                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildSectionTitle(context, "Activity History"),
                            TextButton(
                                onPressed: () {}, child: const Text("See All")),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (walletState.transactions.isEmpty)
                          _buildEmptyActivity(context)
                        else
                          _buildTransactionList(
                              context, walletState.transactions),

                        const SizedBox(
                            height: 100), // Padding for floating nav bar
                      ]),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _actionItem(context, Icons.add_circle_outline, "Top Up",
            theme.colorScheme.primary, () {}),
        _actionItem(context, Icons.send_rounded, "Transfer", Colors.orange,
            () => context.push('/send-money')),
        _actionItem(context, Icons.qr_code_scanner_rounded, "Scan",
            Colors.green, () {}),
        _actionItem(
            context, Icons.more_horiz_rounded, "More", Colors.grey, () {}),
      ],
    );
  }

  Widget _actionItem(BuildContext context, IconData icon, String label,
      Color color, VoidCallback onTap) {
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
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context)
          .textTheme
          .titleMedium
          ?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildBankCarousel(BuildContext context) {
    return SizedBox(
      height: 90,
      child: ListView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        children: [
          _bankCard(context, "Main Chase", "**** 9021", Colors.blue),
          const SizedBox(width: 16),
          _bankCard(context, "Apple Card", "**** 1184", Colors.grey),
          const SizedBox(width: 16),
          _addBankButton(context),
        ],
      ),
    );
  }

  Widget _bankCard(
      BuildContext context, String name, String dots, Color color) {
    final theme = Theme.of(context);
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 30,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13),
                    overflow: TextOverflow.ellipsis),
                Text(dots,
                    style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _addBankButton(BuildContext context) {
    return Container(
      width: 160,
      decoration: BoxDecoration(
        border: Border.all(
            color: Colors.grey.withOpacity(0.2), style: BorderStyle.solid),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
          child: Icon(Icons.add_link_rounded, color: Colors.grey.shade400)),
    );
  }

  Widget _buildTransactionList(
      BuildContext context, List<Transaction> transactions) {
    return Column(
      children: transactions.take(5).map((tx) => _txTile(context, tx)).toList(),
    );
  }

  Widget _txTile(BuildContext context, Transaction tx) {
    final theme = Theme.of(context);
    final isCredit = tx.type == TransactionType.credit;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: (isCredit ? Colors.green : Colors.red).withOpacity(0.1),
                shape: BoxShape.circle),
            child: Icon(isCredit ? Icons.add_rounded : Icons.remove_rounded,
                color: isCredit ? Colors.green : Colors.red, size: 18),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.description,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(tx.date.toString().substring(0, 10),
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Text(
            "${isCredit ? '+' : '-'} \$${tx.amount.toStringAsFixed(2)}",
            style: TextStyle(
                fontWeight: FontWeight.w900,
                color:
                    isCredit ? Colors.green : theme.textTheme.bodyLarge?.color),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyActivity(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(Icons.history_rounded, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text("No recent sessions",
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
