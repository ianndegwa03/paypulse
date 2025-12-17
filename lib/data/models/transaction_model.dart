import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paypulse/domain/entities/enums.dart';
import 'package:paypulse/domain/entities/transaction_entity.dart' as entity;

class TransactionModel extends entity.Transaction {
  const TransactionModel({
    required String id,
    required double amount,
    required String description,
    required DateTime date,
    required String categoryId,
    required String paymentMethodId,
    entity.TransactionType type = entity.TransactionType.debit,
    entity.CurrencyType currency = entity.CurrencyType.USD,
    entity.TransactionStatus status = entity.TransactionStatus.completed,
  }) : super(
          id: id,
          amount: amount,
          description: description,
          date: date,
          categoryId: categoryId,
          paymentMethodId: paymentMethodId,
          type: type,
          currency: currency,
          status: status,
        );

  factory TransactionModel.fromSnapshot(DocumentSnapshot snap) {
    final data = snap.data() as Map<String, dynamic>? ?? {};
    return TransactionModel(
      id: snap.id,
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      description: data['description'] as String? ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      categoryId: data['categoryId'] as String? ?? '',
      paymentMethodId: data['paymentMethodId'] as String? ?? '',
      type: entity.TransactionType.values.firstWhere(
        (e) => e.name == (data['type'] as String? ?? 'debit'),
        orElse: () => entity.TransactionType.debit,
      ),
      currency: entity.CurrencyType.values.firstWhere(
        (e) => e.name == (data['currency'] as String? ?? 'USD'),
        orElse: () => entity.CurrencyType.USD,
      ),
      status: entity.TransactionStatus.values.firstWhere(
        (e) => e.name == (data['status'] as String? ?? 'completed'),
        orElse: () => entity.TransactionStatus.completed,
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
    entity.TransactionType? type,
    entity.CurrencyType? currency,
    entity.TransactionStatus? status,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      date: date ?? this.date,
      categoryId: categoryId ?? this.categoryId,
      paymentMethodId: paymentMethodId ?? this.paymentMethodId,
      type: type ?? this.type,
      currency: currency ?? this.currency,
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
      'currency': currency.name,
      'status': status.name,
    };
  }
}
