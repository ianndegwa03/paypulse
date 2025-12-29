import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paypulse/domain/entities/wallet_entity.dart';
import 'package:paypulse/domain/entities/enums.dart';
import 'package:paypulse/data/models/card_model.dart';
import 'package:paypulse/data/models/vault_model.dart';
import 'package:paypulse/data/models/virtual_card_model.dart';

class WalletModel extends Wallet {
  factory WalletModel.fromEntity(Wallet entity) {
    return WalletModel(
      id: entity.id,
      balance: entity.balance,
      currency: entity.currency,
      hasPlatformWallet: entity.hasPlatformWallet,
      linkedCards: entity.linkedCards,
      vaults: entity.vaults,
      virtualCards: entity.virtualCards,
      isFrozen: entity.isFrozen,
    );
  }

  const WalletModel({
    required super.id,
    required super.balance,
    required super.currency,
    super.hasPlatformWallet,
    super.linkedCards,
    super.vaults,
    super.virtualCards,
    super.isFrozen,
  });

  factory WalletModel.fromSnapshot(DocumentSnapshot snap) {
    if (!snap.exists) return WalletModel.empty();
    final data = snap.data() as Map<String, dynamic>;
    return WalletModel.fromMap(snap.id, data);
  }

  factory WalletModel.empty() {
    return const WalletModel(
      id: '',
      balance: 0.0,
      currency: CurrencyType.USD,
    );
  }

  factory WalletModel.fromMap(String id, Map<String, dynamic> data) {
    return WalletModel(
      id: id,
      balance: (data['balance'] as num).toDouble(),
      currency: CurrencyType.values.firstWhere(
        (e) => e.name == data['currency'],
        orElse: () => CurrencyType.USD,
      ),
      hasPlatformWallet: data['hasPlatformWallet'] ?? false,
      isFrozen: data['isFrozen'] ?? false,
      linkedCards: (data['linkedCards'] as List<dynamic>?)
              ?.map((c) => CardModelMapping.fromMap(c['id'] ?? '', c))
              .toList() ??
          [],
      vaults: (data['vaults'] as List<dynamic>?)
              ?.map((v) => VaultModel.fromMap(v['id'] ?? '', v))
              .toList() ??
          [],
      virtualCards: (data['virtualCards'] as List<dynamic>?)
              ?.map((v) => VirtualCardModel.fromMap(v['id'] ?? '', v))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toDocument() {
    return {
      'balance': balance,
      'currency': currency.name,
      'hasPlatformWallet': hasPlatformWallet,
      'isFrozen': isFrozen,
      'linkedCards':
          linkedCards.map((c) => CardModelMapping.toDocument(c)).toList(),
      'vaults': vaults.map((v) => VaultModel.fromEntity(v).toMap()).toList(),
      'virtualCards': virtualCards
          .map((v) => VirtualCardModel.fromEntity(v).toMap())
          .toList(),
    };
  }
}

class CardModelMapping {
  static CardModel fromMap(String id, Map<String, dynamic> map) {
    return CardModel(
      id: id,
      userId: map['userId'] ?? '',
      lastFour: map['lastFour'] ?? '',
      expiryDate: map['expiryDate'] ?? '',
      cardHolderName: map['cardHolderName'] ?? '',
      type: CardType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => CardType.other,
      ),
      isDefault: map['isDefault'] ?? false,
    );
  }

  static Map<String, dynamic> toDocument(dynamic entity) {
    final model = CardModel.fromEntity(entity);
    return {
      'id': model.id,
      'userId': model.userId,
      'lastFour': model.lastFour,
      'expiryDate': model.expiryDate,
      'cardHolderName': model.cardHolderName,
      'type': model.type.name,
      'isDefault': model.isDefault,
    };
  }
}
