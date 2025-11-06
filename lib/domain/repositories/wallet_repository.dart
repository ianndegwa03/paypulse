import 'package:paypulse/domain/entities/transaction_entity.dart';
import 'package:paypulse/domain/entities/wallet_entity.dart';

abstract class WalletRepository {
  Stream<Wallet> getWallet();
  Stream<List<Transaction>> getTransactions();
  Future<void> addTransaction(Transaction transaction);
}
