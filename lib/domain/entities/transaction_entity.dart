import 'package:equatable/equatable.dart';
import 'package:paypulse/domain/entities/enums.dart';

class Transaction extends Equatable {
  final String id;
  final double amount;
  final String description;
  final DateTime date;
  final String categoryId;
  final String paymentMethodId;
  final TransactionType type;
  final CurrencyType currency;
  final TransactionStatus status;

  const Transaction({
    required this.id,
    required this.amount,
    required this.description,
    required this.date,
    required this.categoryId,
    required this.paymentMethodId,
    this.type = TransactionType.debit,
    this.currency = CurrencyType.USD,
    this.status = TransactionStatus.completed,
  });

  @override
  List<Object?> get props => [
        id,
        amount,
        description,
        date,
        categoryId,
        paymentMethodId,
        type,
        currency,
        status,
      ];
}
