import 'package:paypulse/data/models/transaction_model.dart';

abstract class TransactionDataSource {
  Future<TransactionModel> createTransaction(
      String userId, TransactionModel transaction);
  Future<List<TransactionModel>> getTransactions(
    String userId, {
    String? category,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 20,
    int offset = 0,
  });
  Future<TransactionModel> getTransaction(String userId, String id);
  Future<TransactionModel> categorizeTransaction(
      String userId, String id, String categoryId);
}
