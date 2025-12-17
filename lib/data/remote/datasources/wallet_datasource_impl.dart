import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paypulse/data/models/transaction_model.dart';
import 'package:paypulse/data/models/wallet_model.dart';
import 'package:paypulse/data/remote/datasources/wallet_datasource.dart';

class WalletDataSourceImpl implements WalletDataSource {
  final FirebaseFirestore _firestore;

  WalletDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<WalletModel> getWalletStream(String userId) {
    return _firestore
        .collection('wallets')
        .doc(userId)
        .snapshots()
        .map((doc) => WalletModel.fromSnapshot(doc));
  }

  @override
  Stream<List<TransactionModel>> getTransactionsStream(String userId) {
    return _firestore
        .collection('wallets')
        .doc(userId)
        .collection('transactions')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TransactionModel.fromSnapshot(doc))
            .toList());
  }

  @override
  Future<WalletModel> getWallet(String userId) async {
    final doc = await _firestore.collection('wallets').doc(userId).get();
    if (!doc.exists) {
      throw Exception('Wallet not found');
    }
    return WalletModel.fromSnapshot(doc);
  }

  @override
  Future<void> addMoney(String userId, String amount, String currency) async {
    final walletRef = _firestore.collection('wallets').doc(userId);
    final double amountVal = double.tryParse(amount) ?? 0.0;

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(walletRef);
      if (!snapshot.exists) {
        transaction.set(walletRef, {
          'balance': amountVal,
          'currency': currency,
          'id': userId,
        });
      } else {
        final currentBalance = snapshot.data()?['balance'] ?? 0.0;
        transaction.update(walletRef, {'balance': currentBalance + amountVal});
      }

      final txRef = walletRef.collection('transactions').doc();
      transaction.set(txRef, {
        'id': txRef.id,
        'amount': amountVal,
        'description': 'Deposit',
        'type': 'credit',
        'currency': currency,
        'date': FieldValue.serverTimestamp(),
      });
    });
  }

  @override
  Future<void> transferMoney({
    required String userId,
    required String recipientId,
    required String amount,
    required String currency,
  }) async {
    final walletRef = _firestore.collection('wallets').doc(userId);
    final recipientRef = _firestore.collection('wallets').doc(recipientId);
    final double amountVal = double.tryParse(amount) ?? 0.0;

    await _firestore.runTransaction((transaction) async {
      final senderSnapshot = await transaction.get(walletRef);
      if (!senderSnapshot.exists) {
        throw Exception('Sender wallet not found');
      }

      final currentBalance = senderSnapshot.data()?['balance'] ?? 0.0;
      if (currentBalance < amountVal) {
        throw Exception('Insufficient funds');
      }

      transaction.update(walletRef, {'balance': currentBalance - amountVal});

      final recipientSnapshot = await transaction.get(recipientRef);
      if (recipientSnapshot.exists) {
        final recipientBalance = recipientSnapshot.data()?['balance'] ?? 0.0;
        transaction
            .update(recipientRef, {'balance': recipientBalance + amountVal});
      }

      final senderTxRef = walletRef.collection('transactions').doc();
      transaction.set(senderTxRef, {
        'id': senderTxRef.id,
        'amount': -amountVal,
        'description': 'Transfer to $recipientId',
        'type': 'debit',
        'currency': currency,
        'date': FieldValue.serverTimestamp(),
      });
    });
  }

  @override
  Future<List<TransactionModel>> getTransactions(String userId,
      {int limit = 10, int offset = 0}) async {
    final query = _firestore
        .collection('wallets')
        .doc(userId)
        .collection('transactions')
        .orderBy('date', descending: true)
        .limit(limit);

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => TransactionModel.fromSnapshot(doc))
        .toList();
  }

  @override
  Future<Map<String, dynamic>> getWalletAnalytics(String userId) async {
    return {
      'total_in': 0.0,
      'total_out': 0.0,
      'spending_by_category': {},
    };
  }
}
