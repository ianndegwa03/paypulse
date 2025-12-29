import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paypulse/app/features/multicurrency/presentation/state/multicurrency_provider.dart';
import 'package:paypulse/domain/entities/enums.dart';

class MultiCurrencyWalletScreen extends ConsumerWidget {
  const MultiCurrencyWalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final multiCurrencyState = ref.watch(multiCurrencyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Global Wallet'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildExchangeRateTicker(context, multiCurrencyState.exchangeRates),
          const SizedBox(height: 32),
          Text(
            'Your Currencies',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...multiCurrencyState.balances.entries.map((entry) => _CurrencyCard(
                currency: entry.key,
                balance: entry.value,
              )),
          const SizedBox(height: 32),
          Text(
            'Quick Conversion',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildConversionWidget(context, ref),
        ],
      ),
    );
  }

  Widget _buildExchangeRateTicker(
      BuildContext context, Map<String, double> rates) {
    final theme = Theme.of(context);
    return Container(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: rates.entries
            .map((rate) => Container(
                  margin: const EdgeInsets.only(right: 16),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Text('USD/${rate.key}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 12)),
                      const SizedBox(width: 8),
                      Text(rate.value.toStringAsFixed(2),
                          style: TextStyle(
                              color: theme.colorScheme.primary, fontSize: 12)),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildConversionWidget(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.outlineVariant, width: 0.5),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _currencyDropdown(CurrencyType.USD),
              const Icon(Icons.swap_horiz_rounded, color: Colors.grey),
              _currencyDropdown(CurrencyType.EUR),
            ],
          ),
          const SizedBox(height: 24),
          const TextField(
            decoration: InputDecoration(
              hintText: 'Enter amount',
              prefixText: '\$ ',
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                // Perform conversion
                ref
                    .read(multiCurrencyProvider.notifier)
                    .convert(CurrencyType.USD, CurrencyType.EUR, 100);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Successfully converted \$100 to EUR')),
                );
              },
              child: const Text('Convert Now'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _currencyDropdown(CurrencyType value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(value.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          const Icon(Icons.arrow_drop_down),
        ],
      ),
    );
  }
}

class _CurrencyCard extends StatelessWidget {
  final CurrencyType currency;
  final double balance;

  const _CurrencyCard({required this.currency, required this.balance});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant, width: 0.5),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
            child: Text(_getCurrencySymbol(currency),
                style: TextStyle(color: theme.colorScheme.primary)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(currency.name,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(
                    '${_getCurrencySymbol(currency)}${balance.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Colors.grey),
        ],
      ),
    );
  }

  String _getCurrencySymbol(CurrencyType type) {
    switch (type) {
      case CurrencyType.USD:
        return '\$';
      case CurrencyType.EUR:
        return '€';
      case CurrencyType.GBP:
        return '£';
      case CurrencyType.KES:
        return '/-';
      default:
        return '';
    }
  }
}
