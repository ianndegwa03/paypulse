import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:paypulse/app/features/wallet/presentation/state/wallet_providers.dart';
import 'package:paypulse/domain/entities/transaction_entity.dart';
import 'package:paypulse/domain/entities/enums.dart';

class TransactionsTabScreen extends ConsumerStatefulWidget {
  const TransactionsTabScreen({super.key});

  @override
  ConsumerState<TransactionsTabScreen> createState() =>
      _TransactionsTabScreenState();
}

class _TransactionsTabScreenState extends ConsumerState<TransactionsTabScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final walletState = ref.watch(walletStateProvider);
    final transactions = walletState.transactions
        .where((t) =>
            t.description.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("History",
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: "Search transactions...",
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = "");
                        },
                      )
                    : null,
                filled: true,
                fillColor: theme.cardColor,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none),
              ),
            ),
          ),

          // Filters (Mock)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                _filterChip("All", true),
                _filterChip("Expenses", false),
                _filterChip("Income", false),
                _filterChip("Subscriptions", false),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Transaction List
          Expanded(
            child: transactions.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final tx = transactions[index];
                      return _buildTransactionTile(context, tx);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, bool isSelected) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (v) {},
        backgroundColor: theme.cardColor,
        selectedColor: theme.colorScheme.primary.withOpacity(0.2),
        labelStyle: TextStyle(
            color: isSelected ? theme.colorScheme.primary : Colors.grey,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
        showCheckmark: false,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildTransactionTile(BuildContext context, Transaction tx) {
    final theme = Theme.of(context);
    final isDebit = tx.type == TransactionType.debit;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showTransactionDetails(context, tx),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(20),
            border:
                Border.all(color: theme.colorScheme.outline.withOpacity(0.05)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (isDebit ? Colors.red : Colors.green).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isDebit ? Icons.arrow_downward : Icons.arrow_upward,
                  color: isDebit ? Colors.red : Colors.green,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tx.description,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(DateFormat('MMM dd, hh:mm a').format(tx.date),
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              Text(
                "${isDebit ? '-' : '+'}\$${tx.amount.abs().toStringAsFixed(2)}",
                style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color:
                        isDebit ? theme.colorScheme.onSurface : Colors.green),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_rounded,
              size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text("No transactions found",
              style:
                  TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showTransactionDetails(BuildContext context, Transaction tx) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 24),
            const Text("Transaction Details",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            Text("\$${tx.amount.abs().toStringAsFixed(2)}",
                style:
                    const TextStyle(fontSize: 48, fontWeight: FontWeight.w900)),
            Text(tx.description, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 48),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showSplitBillSheet(context, tx);
                    },
                    icon: const Icon(Icons.splitscreen_rounded),
                    label: const Text("Split Bill"),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.share_rounded),
                    label: const Text("Receipt"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showSplitBillSheet(BuildContext context, Transaction tx) {
    // This is where we would lead to a specialized Split Bill screen or logic
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
          "Splitting \$${tx.amount.abs().toStringAsFixed(2)} for ${tx.description}"),
      behavior: SnackBarBehavior.floating,
    ));
  }
}
