import 'package:paypulse/domain/entities/virtual_card_entity.dart';

class VirtualCardModel extends VirtualCardEntity {
  const VirtualCardModel({
    required super.id,
    required super.cardNumber,
    required super.expiryDate,
    required super.cvv,
    required super.label,
    super.hexColor,
    super.isDisposable,
    super.isActive,
    super.isGhostCard,
    super.destructionDate,
    super.merchantLock,
    super.maxTransactionLimit,
    super.anonymityScore,
    super.cardHolderName = 'PAYPULSE USER',
    super.design = CardDesign.metalBlack,
    super.network = CardNetwork.visa,
  });

  factory VirtualCardModel.fromEntity(VirtualCardEntity entity) {
    return VirtualCardModel(
      id: entity.id,
      cardNumber: entity.cardNumber,
      expiryDate: entity.expiryDate,
      cvv: entity.cvv,
      label: entity.label,
      hexColor: entity.hexColor,
      isDisposable: entity.isDisposable,
      isActive: entity.isActive,
      isGhostCard: entity.isGhostCard,
      destructionDate: entity.destructionDate,
      merchantLock: entity.merchantLock,
      maxTransactionLimit: entity.maxTransactionLimit,
      anonymityScore: entity.anonymityScore,
      cardHolderName: entity.cardHolderName,
      design: entity.design,
      network: entity.network,
    );
  }

  factory VirtualCardModel.fromMap(String id, Map<String, dynamic> map) {
    return VirtualCardModel(
      id: id,
      cardNumber: map['cardNumber'] ?? '',
      expiryDate: map['expiryDate'] ?? '',
      cvv: map['cvv'] ?? '',
      label: map['label'] ?? '',
      hexColor: map['hexColor'] ?? '#000000',
      isDisposable: map['isDisposable'] ?? false,
      isActive: map['isActive'] ?? true,
      isGhostCard: map['isGhostCard'] ?? false,
      destructionDate: map['destructionDate'] != null
          ? DateTime.parse(map['destructionDate'])
          : null,
      merchantLock: map['merchantLock'],
      maxTransactionLimit: map['maxTransactionLimit']?.toDouble(),
      anonymityScore: map['anonymityScore'] ?? 0,
      cardHolderName: map['cardHolderName'] ?? 'PAYPULSE USER',
      // design and network would need parsing from string/int, simplify for now
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cardNumber': cardNumber,
      'expiryDate': expiryDate,
      'cvv': cvv,
      'label': label,
      'hexColor': hexColor,
      'isDisposable': isDisposable,
      'isActive': isActive,
      'isGhostCard': isGhostCard,
      'destructionDate': destructionDate?.toIso8601String(),
      'merchantLock': merchantLock,
      'maxTransactionLimit': maxTransactionLimit,
      'anonymityScore': anonymityScore,
    };
  }
}
