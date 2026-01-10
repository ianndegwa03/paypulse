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
    return TransactionModel.fromJson(data..['id'] = snap.id);
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] as String? ?? '',
      date: json['date'] is Timestamp
          ? (json['date'] as Timestamp).toDate()
          : (json['date'] is String
              ? DateTime.tryParse(json['date']) ?? DateTime.now()
              : DateTime.now()),
      categoryId: json['categoryId'] as String? ?? '',
      paymentMethodId: json['paymentMethodId'] as String? ?? '',
      type: TransactionType.values.firstWhere(
        (e) => e.name == (json['type'] as String? ?? 'debit'),
        orElse: () => TransactionType.debit,
      ),
      currencyCode: json['currency'] as String? ?? 'USD',
      targetCurrencyCode: json['targetCurrency'],
      exchangeRate: (json['exchangeRate'] as num?)?.toDouble(),
      status: TransactionStatus.values.firstWhere(
        (e) => e.name == (json['status'] as String? ?? 'completed'),
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'description': description,
      'date': date.toIso8601String(),
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
