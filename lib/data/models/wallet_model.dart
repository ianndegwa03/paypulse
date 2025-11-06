import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paypulse/domain/entities/wallet_entity.dart';

class WalletModel extends Wallet {
  const WalletModel({
    required String id,
    required double balance,
    required String currency,
  }) : super(id: id, balance: balance, currency: currency);

  factory WalletModel.fromSnapshot(DocumentSnapshot snap) {
    return WalletModel(
      id: snap.id,
      balance: snap['balance'],
      currency: snap['currency'],
    );
  }

  Map<String, dynamic> toDocument() {
    return {
      'balance': balance,
      'currency': currency,
    };
  }
}
