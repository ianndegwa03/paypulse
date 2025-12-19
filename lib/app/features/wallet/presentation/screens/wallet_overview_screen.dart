import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:paypulse/app/features/wallet/presentation/state/wallet_providers.dart';

class WalletOverviewScreen extends ConsumerWidget {
  const WalletOverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletState = ref.watch(walletStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet'),
        actions: [
          IconButton(
            onPressed: () {
              context.push('/add-transaction');
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          if (walletState.isLoading && walletState.wallet == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (walletState.errorMessage != null && walletState.wallet == null) {
            return Center(child: Text(walletState.errorMessage!));
          }
          if (walletState.wallet != null) {
            return Column(
              children: [
                Text(
                    'Balance: ${walletState.wallet!.balance} ${walletState.wallet!.currency}'),
                Expanded(
                  child: ListView.builder(
                    itemCount: walletState.transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = walletState.transactions[index];
                      return ListTile(
                        title: Text(transaction.description),
                        subtitle: Text(transaction.date.toString()),
                        trailing: Text('${transaction.amount}'),
                        onTap: () {
                          context.push('/transaction-details',
                              extra: transaction);
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          }
          return const Center(child: Text('No wallet data found'));
        },
      ),
    );
  }
}
