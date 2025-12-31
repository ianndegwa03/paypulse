import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paypulse/domain/entities/enums.dart';
import 'package:paypulse/domain/entities/transaction_entity.dart' as entity;

class TransactionModel extends entity.Transaction {
  const TransactionModel({
    required super.id,
    required super.amount,
    required super.description,
    required super.date,
    required super.categoryId,
    required super.paymentMethodId,
    super.type,
    super.currencyCode,
    super.targetCurrencyCode,
    super.exchangeRate,
    super.status,
  });

  factory TransactionModel.fromSnapshot(DocumentSnapshot snap) {
    final data = snap.data() as Map<String, dynamic>? ?? {};
    return TransactionModel(
      id: snap.id,
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      description: data['description'] as String? ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      categoryId: data['categoryId'] as String? ?? '',
      paymentMethodId: data['paymentMethodId'] as String? ?? '',
      type: TransactionType.values.firstWhere(
        (e) => e.name == (data['type'] as String? ?? 'debit'),
        orElse: () => TransactionType.debit,
      ),
      currencyCode: data['currency'] as String? ?? 'USD',
      targetCurrencyCode: data['targetCurrency'],
      exchangeRate: (data['exchangeRate'] as num?)?.toDouble(),
      status: TransactionStatus.values.firstWhere(
        (e) => e.name == (data['status'] as String? ?? 'completed'),
        orElse: () => TransactionStatus.completed,
      ),
    );
  }

  TransactionModel copyWith({
    String? id,
    double? amount,
    String? description,
    DateTime? date,
    String? categoryId,
    String? paymentMethodId,
    TransactionType? type,
    String? currencyCode,
    String? targetCurrencyCode,
    double? exchangeRate,
    TransactionStatus? status,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      date: date ?? this.date,
      categoryId: categoryId ?? this.categoryId,
      paymentMethodId: paymentMethodId ?? this.paymentMethodId,
      type: type ?? this.type,
      currencyCode: currencyCode ?? this.currencyCode,
      targetCurrencyCode: targetCurrencyCode ?? this.targetCurrencyCode,
      exchangeRate: exchangeRate ?? this.exchangeRate,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toDocument() {
    return {
      'amount': amount,
      'description': description,
      'date': Timestamp.fromDate(date),
      'categoryId': categoryId,
      'paymentMethodId': paymentMethodId,
      'type': type.name,
      'currency': currencyCode,
      'targetCurrency': targetCurrencyCode,
      'exchangeRate': exchangeRate,
      'status': status.name,
    };
  }
}
