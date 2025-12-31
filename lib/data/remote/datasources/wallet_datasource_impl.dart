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
    if (!doc.exists) throw Exception('Wallet not found');
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
          'balances': {currency: amountVal},
          'primaryCurrency': currency,
          'id': userId
        });
      } else {
        final data = snapshot.data();
        final balances = Map<String, dynamic>.from(data?['balances'] ?? {});
        // fallback for legacy
        if (balances.isEmpty && data?['balance'] != null) {
          balances[data?['currency'] ?? 'USD'] = data?['balance'];
        }

        final currentBalance = (balances[currency] as num?)?.toDouble() ?? 0.0;
        balances[currency] = currentBalance + amountVal;

        transaction.update(walletRef, {'balances': balances});
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
  Future<void> transferMoney(
      {required String userId,
      required String recipientId,
      required String amount,
      required String currency}) async {
    final walletRef = _firestore.collection('wallets').doc(userId);
    final recipientRef = _firestore.collection('wallets').doc(recipientId);
    final double amountVal = double.tryParse(amount) ?? 0.0;

    await _firestore.runTransaction((transaction) async {
      final senderSnapshot = await transaction.get(walletRef);
      if (!senderSnapshot.exists) throw Exception('Sender wallet not found');

      final senderData = senderSnapshot.data();
      final senderBalances =
          Map<String, dynamic>.from(senderData?['balances'] ?? {});
      // fallback for legacy
      if (senderBalances.isEmpty && senderData?['balance'] != null) {
        senderBalances[senderData?['currency'] ?? 'USD'] =
            senderData?['balance'];
      }

      final senderCurrentBalance =
          (senderBalances[currency] as num?)?.toDouble() ?? 0.0;
      if (senderCurrentBalance < amountVal)
        throw Exception('Insufficient funds');

      senderBalances[currency] = senderCurrentBalance - amountVal;
      transaction.update(walletRef, {'balances': senderBalances});

      final recipientSnapshot = await transaction.get(recipientRef);
      if (recipientSnapshot.exists) {
        final recipientData = recipientSnapshot.data();
        final recipientBalances =
            Map<String, dynamic>.from(recipientData?['balances'] ?? {});
        // fallback for legacy
        if (recipientBalances.isEmpty && recipientData?['balance'] != null) {
          recipientBalances[recipientData?['currency'] ?? 'USD'] =
              recipientData?['balance'];
        }

        final recipientCurrentBalance =
            (recipientBalances[currency] as num?)?.toDouble() ?? 0.0;
        recipientBalances[currency] = recipientCurrentBalance + amountVal;

        transaction.update(recipientRef, {'balances': recipientBalances});
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
    final snapshot = await _firestore
        .collection('wallets')
        .doc(userId)
        .collection('transactions')
        .orderBy('date', descending: true)
        .limit(limit)
        .get();
    return snapshot.docs
        .map((doc) => TransactionModel.fromSnapshot(doc))
        .toList();
  }

  @override
  Future<Map<String, dynamic>> getWalletAnalytics(String userId) async {
    final query = await _firestore
        .collection('wallets')
        .doc(userId)
        .collection('transactions')
        .get();
    double totalIn = 0.0, totalOut = 0.0;
    for (var doc in query.docs) {
      final amount = (doc.data()['amount'] as num?)?.toDouble() ?? 0.0;
      if (amount > 0)
        totalIn += amount;
      else
        totalOut += amount.abs();
    }
    return {
      'total_in': totalIn,
      'total_out': totalOut,
      'spending_by_category': {'General': totalOut}
    };
  }

  @override
  Future<void> updateWallet(String userId, WalletModel wallet) async {
    await _firestore
        .collection('wallets')
        .doc(userId)
        .set(wallet.toDocument(), SetOptions(merge: true));
  }

  @override
  Future<void> linkCard(String userId, Map<String, dynamic> cardData) async {
    await _firestore.collection('wallets').doc(userId).update({
      'linkedCards': FieldValue.arrayUnion([cardData])
    });
  }

  @override
  Future<void> createVault(
      String userId, Map<String, dynamic> vaultData) async {
    await _firestore.collection('wallets').doc(userId).update({
      'vaults': FieldValue.arrayUnion([vaultData])
    });
  }

  @override
  Future<void> fundVault(String userId, String vaultId, double amount) async {
    final walletRef = _firestore.collection('wallets').doc(userId);
    await _firestore.runTransaction((transaction) async {
      final snap = await transaction.get(walletRef);
      if (!snap.exists) return;
      final data = snap.data()!;

      final balances = Map<String, dynamic>.from(data['balances'] ?? {});
      // fallback for legacy - assuming USD for vaults for now or primary
      String primaryCurrency =
          data['primaryCurrency'] ?? data['currency'] ?? 'USD';
      if (balances.isEmpty && data['balance'] != null) {
        balances[primaryCurrency] = data['balance'];
      }

      final double balance =
          (balances[primaryCurrency] as num?)?.toDouble() ?? 0.0;

      if (balance < amount) throw Exception('Insufficient balance');

      final List<dynamic> vaults = List.from(data['vaults'] ?? []);
      final index = vaults.indexWhere((v) => v['id'] == vaultId);
      if (index == -1) throw Exception('Vault not found');

      final vault = Map<String, dynamic>.from(vaults[index]);
      vault['currentAmount'] =
          (vault['currentAmount'] as num).toDouble() + amount;
      vaults[index] = vault;

      balances[primaryCurrency] = balance - amount;

      transaction.update(walletRef, {'balances': balances, 'vaults': vaults});
    });
  }

  @override
  Future<void> createVirtualCard(
      String userId, Map<String, dynamic> cardData) async {
    await _firestore.collection('wallets').doc(userId).update({
      'virtualCards': FieldValue.arrayUnion([cardData])
    });
  }
}
