import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:paypulse/data/models/transaction_model.dart';
import 'package:paypulse/data/models/wallet_model.dart';
import 'package:paypulse/domain/entities/transaction_entity.dart' as domain;
import 'package:paypulse/domain/entities/wallet_entity.dart';
import 'package:paypulse/domain/repositories/wallet_repository.dart';

class WalletRepositoryImpl implements WalletRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  WalletRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? firebaseAuth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  String get _userId => _firebaseAuth.currentUser!.uid;

  @override
  Stream<Wallet> getWallet() {
    return _firestore
        .collection('wallets')
        .doc(_userId)
        .snapshots()
        .map((doc) => WalletModel.fromSnapshot(doc));
  }

  @override
  Stream<List<domain.Transaction>> getTransactions() {
    return _firestore
        .collection('wallets')
        .doc(_userId)
        .collection('transactions')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => TransactionModel.fromSnapshot(doc)).toList());
  }

  @override
  Future<void> addTransaction(domain.Transaction transaction) async {
    final transactionModel = TransactionModel(
      id: transaction.id,
      amount: transaction.amount,
      description: transaction.description,
      date: transaction.date,
      categoryId: transaction.categoryId,
      paymentMethodId: transaction.paymentMethodId,
    );
    await _firestore
        .collection('wallets')
        .doc(_userId)
        .collection('transactions')
        .add(transactionModel.toDocument());
  }
}
