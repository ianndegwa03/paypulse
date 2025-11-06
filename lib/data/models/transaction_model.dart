import 'package:cloud_firestore/cloud_firestore.dart';
import 'package.paypulse/domain/entities/transaction_entity.dart';

class TransactionModel extends Transaction {
  const TransactionModel({
    required String id,
    required double amount,
    required String description,
    required DateTime date,
    required String categoryId,
    required String paymentMethodId,
  }) : super(
          id: id,
          amount: amount,
          description: description,
          date: date,
          categoryId: categoryId,
          paymentMethodId: paymentMethodId,
        );

  factory TransactionModel.fromSnapshot(DocumentSnapshot snap) {
    return TransactionModel(
      id: snap.id,
      amount: snap['amount'],
      description: snap['description'],
      date: (snap['date'] as Timestamp).toDate(),
      categoryId: snap['categoryId'],
      paymentMethodId: snap['paymentMethodId'],
    );
  }

  Map<String, dynamic> toDocument() {
    return {
      'amount': amount,
      'description': description,
      'date': Timestamp.fromDate(date),
      'categoryId': categoryId,
      'paymentMethodId': paymentMethodId,
    };
  }
}
