import 'package:equatable/equatable.dart';
import 'package:paypulse/domain/entities/enums.dart';
import 'package:paypulse/domain/entities/card_entity.dart';
import 'package:paypulse/domain/entities/vault_entity.dart';
import 'package:paypulse/domain/entities/virtual_card_entity.dart';

class Wallet extends Equatable {
  final String id;
  final double balance;
  final CurrencyType currency;
  final bool hasPlatformWallet;
  final List<CardEntity> linkedCards;
  final List<VaultEntity> vaults;
  final List<VirtualCardEntity> virtualCards;
  final bool isFrozen;

  const Wallet({
    required this.id,
    required this.balance,
    required this.currency,
    this.hasPlatformWallet = false,
    this.linkedCards = const [],
    this.vaults = const [],
    this.virtualCards = const [],
    this.isFrozen = false,
  });

  @override
  List<Object?> get props => [
        id,
        balance,
        currency,
        hasPlatformWallet,
        linkedCards,
        vaults,
        virtualCards,
        isFrozen
      ];

  Wallet copyWith({
    String? id,
    double? balance,
    CurrencyType? currency,
    bool? hasPlatformWallet,
    List<CardEntity>? linkedCards,
    List<VaultEntity>? vaults,
    List<VirtualCardEntity>? virtualCards,
    bool? isFrozen,
  }) {
    return Wallet(
      id: id ?? this.id,
      balance: balance ?? this.balance,
      currency: currency ?? this.currency,
      hasPlatformWallet: hasPlatformWallet ?? this.hasPlatformWallet,
      linkedCards: linkedCards ?? this.linkedCards,
      vaults: vaults ?? this.vaults,
      virtualCards: virtualCards ?? this.virtualCards,
      isFrozen: isFrozen ?? this.isFrozen,
    );
  }
}
