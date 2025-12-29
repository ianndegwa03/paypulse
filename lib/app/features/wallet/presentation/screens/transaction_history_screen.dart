import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:paypulse/app/features/wallet/presentation/state/wallet_providers.dart';
import 'package:paypulse/domain/entities/transaction_entity.dart';
import 'package:paypulse/domain/entities/enums.dart';

class TransactionHistoryScreen extends ConsumerStatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  ConsumerState<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState
    extends ConsumerState<TransactionHistoryScreen> {
  String _searchQuery = '';
  TransactionType? _typeFilter;
  DateTimeRange? _dateRange;

  @override
  Widget build(BuildContext context) {
    final walletState = ref.watch(walletStateProvider);

    final filteredTransactions = walletState.transactions.where((tx) {
      final matchesSearch =
          tx.description.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesType = _typeFilter == null || tx.type == _typeFilter;
      final matchesDate = _dateRange == null ||
          (tx.date.isAfter(_dateRange!.start) &&
              tx.date.isBefore(_dateRange!.end.add(const Duration(days: 1))));

      return matchesSearch && matchesType && matchesDate;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () => _showFilterSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SearchBar(
              hintText: 'Search transactions...',
              leading: const Icon(Icons.search),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          if (_typeFilter != null || _dateRange != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Wrap(
                spacing: 8,
                children: [
                  if (_typeFilter != null)
                    Chip(
                      label: Text(_typeFilter == TransactionType.credit
                          ? 'Income'
                          : 'Expense'),
                      onDeleted: () => setState(() => _typeFilter = null),
                    ),
                  if (_dateRange != null)
                    Chip(
                      label: Text(
                          '${DateFormat('MMM d').format(_dateRange!.start)} - ${DateFormat('MMM d').format(_dateRange!.end)}'),
                      onDeleted: () => setState(() => _dateRange = null),
                    ),
                ],
              ),
            ),
          Expanded(
            child: filteredTransactions.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredTransactions.length,
                    itemBuilder: (context, index) {
                      final tx = filteredTransactions[index];
                      return _TransactionTile(tx: tx);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text('No transactions found',
              style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Filter by Type',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  SegmentedButton<TransactionType?>(
                    segments: const [
                      ButtonSegment(value: null, label: Text('All')),
                      ButtonSegment(
                          value: TransactionType.credit, label: Text('Income')),
                      ButtonSegment(
                          value: TransactionType.debit, label: Text('Expense')),
                    ],
                    selected: {_typeFilter},
                    onSelectionChanged: (newSelection) {
                      setState(() => _typeFilter = newSelection.first);
                      setSheetState(() {});
                    },
                  ),
                  const SizedBox(height: 24),
                  Text('Date Range',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  ListTile(
                    title: Text(_dateRange == null
                        ? 'Select Date Range'
                        : '${DateFormat('MMM d, y').format(_dateRange!.start)} - ${DateFormat('MMM d, y').format(_dateRange!.end)}'),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                        initialDateRange: _dateRange,
                      );
                      if (picked != null) {
                        setState(() => _dateRange = picked);
                        setSheetState(() {});
                      }
                    },
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Apply Filters'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final Transaction tx;
  const _TransactionTile({required this.tx});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCredit = tx.type == TransactionType.credit;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant, width: 0.5),
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
                Text(DateFormat('MMM d, h:mm a').format(tx.date),
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
}
