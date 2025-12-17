import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paypulse/data/models/transaction_model.dart';
import 'package:paypulse/data/remote/datasources/transaction_datasource.dart';

class TransactionDataSourceImpl implements TransactionDataSource {
  final FirebaseFirestore _firestore;

  TransactionDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<TransactionModel> createTransaction(
      String userId, TransactionModel transaction) async {
    final docRef = _firestore
        .collection('wallets')
        .doc(userId)
        .collection('transactions')
        .doc();

    final model = transaction.copyWith(id: docRef.id);
    await docRef.set(model.toDocument());
    return model;
  }

  @override
  Future<List<TransactionModel>> getTransactions(
    String userId, {
    String? category,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 20,
    int offset = 0,
  }) async {
    Query query = _firestore
        .collection('wallets')
        .doc(userId)
        .collection('transactions')
        .orderBy('date', descending: true);

    if (category != null) {
      query = query.where('categoryId', isEqualTo: category);
    }

    if (startDate != null) {
      query = query.where('date',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
    }
    if (endDate != null) {
      query =
          query.where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
    }

    query = query.limit(limit);

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => TransactionModel.fromSnapshot(doc))
        .toList();
  }

  @override
  Future<TransactionModel> getTransaction(String userId, String id) async {
    final doc = await _firestore
        .collection('wallets')
        .doc(userId)
        .collection('transactions')
        .doc(id)
        .get();

    if (!doc.exists) {
      throw Exception('Transaction not found');
    }

    return TransactionModel.fromSnapshot(doc);
  }

  @override
  Future<TransactionModel> categorizeTransaction(
      String userId, String id, String categoryId) async {
    final docRef = _firestore
        .collection('wallets')
        .doc(userId)
        .collection('transactions')
        .doc(id);

    await docRef.update({'categoryId': categoryId});

    final updated = await docRef.get();
    return TransactionModel.fromSnapshot(updated);
  }
}
