import 'package:flutter/material.dart';
import 'package:paypulse/domain/entities/transaction_entity.dart';

class TransactionDetailsScreen extends StatelessWidget {
  final Transaction transaction;

  const TransactionDetailsScreen({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Details'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Description: \${transaction.description}'),
            Text('Amount: \${transaction.amount}'),
            Text('Date: \${transaction.date}'),
            Text('Category ID: \${transaction.categoryId}'),
            Text('Payment Method ID: \${transaction.paymentMethodId}'),
          ],
        ),
      ),
    );
  }
}
