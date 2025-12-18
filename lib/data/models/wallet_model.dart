import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paypulse/domain/entities/wallet_entity.dart';

import 'package:paypulse/domain/entities/enums.dart';

class WalletModel extends Wallet {
  const WalletModel({
    required super.id,
    required super.balance,
    required super.currency,
  });

  factory WalletModel.fromSnapshot(DocumentSnapshot snap) {
    return WalletModel(
      id: snap.id,
      balance: (snap['balance'] as num).toDouble(),
      currency: CurrencyType.values.firstWhere(
        (e) => e.name == (snap['currency'] as String),
        orElse: () => CurrencyType.USD,
      ),
    );
  }

  Map<String, dynamic> toDocument() {
    return {
      'balance': balance,
      'currency': currency.name,
    };
  }
}
