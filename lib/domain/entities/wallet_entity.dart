import 'package:equatable/equatable.dart';
import 'package:paypulse/domain/entities/enums.dart';
import 'package:paypulse/domain/entities/card_entity.dart';
import 'package:paypulse/domain/entities/vault_entity.dart';
import 'package:paypulse/domain/entities/virtual_card_entity.dart';

class Wallet extends Equatable {
  final String id;
  final Map<String, double> balances;
  final String primaryCurrency;
  final bool hasPlatformWallet;
  final List<CardEntity> linkedCards;
  final List<VaultEntity> vaults;
  final List<VirtualCardEntity> virtualCards;
  final Map<String, double> costBasis; // Average purchase price in USD
  final bool isFrozen;

  const Wallet({
    required this.id,
    this.balances = const {},
    this.costBasis = const {},
    this.primaryCurrency = 'USD',
    this.hasPlatformWallet = false,
    this.linkedCards = const [],
    this.vaults = const [],
    this.virtualCards = const [],
    this.isFrozen = false,
  });

  // Backward compatibility getters
  double get balance => balances[primaryCurrency] ?? 0.0;

  CurrencyType get currency {
    try {
      return CurrencyType.values.firstWhere(
        (e) => e.name.toUpperCase() == primaryCurrency.toUpperCase(),
        orElse: () => CurrencyType.USD,
      );
    } catch (_) {
      return CurrencyType.USD;
    }
  }

  @override
  List<Object?> get props => [
        id,
        balances,
        costBasis,
        primaryCurrency,
        hasPlatformWallet,
        linkedCards,
        vaults,
        virtualCards,
        isFrozen
      ];

  Wallet copyWith({
    String? id,
    Map<String, double>? balances,
    Map<String, double>? costBasis,
    String? primaryCurrency,
    bool? hasPlatformWallet,
    List<CardEntity>? linkedCards,
    List<VaultEntity>? vaults,
    List<VirtualCardEntity>? virtualCards,
    bool? isFrozen,
  }) {
    return Wallet(
      id: id ?? this.id,
      balances: balances ?? this.balances,
      costBasis: costBasis ?? this.costBasis,
      primaryCurrency: primaryCurrency ?? this.primaryCurrency,
      hasPlatformWallet: hasPlatformWallet ?? this.hasPlatformWallet,
      linkedCards: linkedCards ?? this.linkedCards,
      vaults: vaults ?? this.vaults,
      virtualCards: virtualCards ?? this.virtualCards,
      isFrozen: isFrozen ?? this.isFrozen,
    );
  }
}
