import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paypulse/app/features/bills/presentation/state/bill_provider.dart';
import 'package:paypulse/domain/entities/bill_entity.dart';
import 'package:intl/intl.dart';

class BillReminderScreen extends ConsumerWidget {
  const BillReminderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final billState = ref.watch(billProvider);

    final pendingBills = billState.bills.where((b) => !b.isPaid).toList();
    final paidBills = billState.bills.where((b) => b.isPaid).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bill Reminders'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (pendingBills.isNotEmpty) ...[
            Text(
              'Upcoming Bills',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...pendingBills.map((bill) => _BillCard(bill: bill)),
            const SizedBox(height: 32),
          ],
          if (paidBills.isNotEmpty) ...[
            Text(
              'Recently Paid',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ...paidBills.map((bill) => _BillCard(bill: bill)),
          ],
          if (billState.bills.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Text('No bills tracked yet.'),
              ),
            ),
        ],
      ),
    );
  }
}

class _BillCard extends ConsumerWidget {
  final BillEntity bill;
  const _BillCard({required this.bill});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isOverdue = !bill.isPaid && bill.dueDate.isBefore(DateTime.now());

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOverdue
              ? Colors.red.withOpacity(0.5)
              : theme.colorScheme.outlineVariant,
          width: isOverdue ? 1 : 0.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (bill.isPaid
                          ? Colors.green
                          : (isOverdue
                              ? Colors.red
                              : theme.colorScheme.primary))
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  bill.isPaid
                      ? Icons.check_circle_rounded
                      : Icons.pending_actions_rounded,
                  color: bill.isPaid
                      ? Colors.green
                      : (isOverdue ? Colors.red : theme.colorScheme.primary),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bill.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      'Due ${DateFormat('MMM d, y').format(bill.dueDate)}',
                      style: TextStyle(
                        color: isOverdue ? Colors.red : Colors.grey,
                        fontSize: 12,
                        fontWeight:
                            isOverdue ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${bill.amount.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    bill.payee,
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (!bill.isPaid)
                TextButton(
                  onPressed: () {
                    ref.read(billProvider.notifier).togglePaid(bill.id);
                  },
                  child: const Text('Mark as Paid'),
                ),
              if (bill.isPaid)
                const Text(
                  'Paid',
                  style: TextStyle(
                      color: Colors.green, fontWeight: FontWeight.bold),
                ),
              const SizedBox(width: 8),
              if (!bill.isPaid)
                FilledButton.tonal(
                  onPressed: () {
                    // Navigate to payment
                  },
                  child: const Text('Pay Now'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
