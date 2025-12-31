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
  final String currencyCode;
  final String? targetCurrencyCode;
  final double? exchangeRate;
  final TransactionStatus status;

  const Transaction({
    required this.id,
    required this.amount,
    required this.description,
    required this.date,
    required this.categoryId,
    required this.paymentMethodId,
    this.type = TransactionType.debit,
    this.currencyCode = 'USD',
    this.targetCurrencyCode,
    this.exchangeRate,
    this.status = TransactionStatus.completed,
  });

  // Backward compatibility
  CurrencyType get currency {
    try {
      return CurrencyType.values.firstWhere(
        (e) => e.name.toUpperCase() == currencyCode.toUpperCase(),
        orElse: () => CurrencyType.USD,
      );
    } catch (_) {
      return CurrencyType.USD;
    }
  }

  @override
  List<Object?> get props => [
        id,
        amount,
        description,
        date,
        categoryId,
        paymentMethodId,
        type,
        currencyCode,
        targetCurrencyCode,
        exchangeRate,
        status,
      ];
}
