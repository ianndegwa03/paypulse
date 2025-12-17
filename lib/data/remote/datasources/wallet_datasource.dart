import 'package:paypulse/data/models/transaction_model.dart';
import 'package:paypulse/data/models/wallet_model.dart';

abstract class WalletDataSource {
  Stream<WalletModel> getWalletStream(String userId);
  Stream<List<TransactionModel>> getTransactionsStream(String userId);
  Future<WalletModel> getWallet(String userId);
  Future<void> addMoney(String userId, String amount, String currency);
  Future<void> transferMoney({
    required String userId,
    required String recipientId,
    required String amount,
    required String currency,
  });
  Future<List<TransactionModel>> getTransactions(String userId,
      {int limit = 10, int offset = 0});
  Future<Map<String, dynamic>> getWalletAnalytics(String userId);
}
