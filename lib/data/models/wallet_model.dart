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
      balances: entity.balances,
      primaryCurrency: entity.primaryCurrency,
      hasPlatformWallet: entity.hasPlatformWallet,
      linkedCards: entity.linkedCards,
      vaults: entity.vaults,
      virtualCards: entity.virtualCards,
      costBasis: entity.costBasis,
      isFrozen: entity.isFrozen,
    );
  }

  const WalletModel({
    required super.id,
    super.balances,
    super.costBasis,
    super.primaryCurrency,
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
      balances: {'USD': 0.0},
      costBasis: {'USD': 1.0},
      primaryCurrency: 'USD',
    );
  }

  factory WalletModel.fromMap(String id, Map<String, dynamic> data) {
    // Handle legacy data or new balances map
    final Map<String, double> balances = {};
    final Map<String, double> costBasis = {};

    if (data['balances'] != null) {
      final map = data['balances'] as Map<String, dynamic>;
      map.forEach((key, value) {
        balances[key] = (value as num).toDouble();
      });
    }

    if (data['costBasis'] != null) {
      final map = data['costBasis'] as Map<String, dynamic>;
      map.forEach((key, value) {
        costBasis[key] = (value as num).toDouble();
      });
    }

    // Ensure at least USD exists if empty
    if (balances.isEmpty) {
      balances['USD'] = 0.0;
    }

    return WalletModel(
      id: id,
      balances: balances,
      costBasis: costBasis,
      primaryCurrency: data['primaryCurrency'] ?? data['currency'] ?? 'USD',
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
      'balances': balances,
      'costBasis': costBasis,
      'primaryCurrency': primaryCurrency,
      // derived fields for legacy support if needed
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
