import 'package:equatable/equatable.dart';

enum CardDesign { metalBlack, cyberNeon, glassFrost, goldLuxury }

enum CardNetwork { visa, mastercard }

class VirtualCardEntity extends Equatable {
  // Legacy Fields
  final String id;
  final String cardNumber;
  final String expiryDate; // Keeping as String to match legacy model
  final String cvv;
  final String label;
  final String hexColor;
  final bool isDisposable;
  final bool isActive;
  final bool isGhostCard;
  final DateTime? destructionDate;
  final String? merchantLock;
  final double? maxTransactionLimit;
  final int anonymityScore;

  // New Premium Fields
  final String cardHolderName;
  final CardDesign design;
  final CardNetwork network;

  const VirtualCardEntity({
    required this.id,
    required this.cardNumber,
    required this.expiryDate,
    required this.cvv,
    required this.label,
    this.hexColor = '#000000',
    this.isDisposable = false,
    this.isActive = true,
    this.isGhostCard = false,
    this.destructionDate,
    this.merchantLock,
    this.maxTransactionLimit,
    this.anonymityScore = 0,
    this.cardHolderName = 'PAYPULSE USER',
    this.design = CardDesign.metalBlack,
    this.network = CardNetwork.visa,
  });

  // Helper getters for Premium UI
  String get last4 => cardNumber.length >= 4
      ? cardNumber.substring(cardNumber.length - 4)
      : '0000';
  DateTime get expiryDateObject {
    // Try parse MM/YY or similar if needed, or return default
    return DateTime.now().add(const Duration(days: 365 * 3));
  }

  VirtualCardEntity copyWith({
    String? id,
    String? cardNumber,
    String? expiryDate,
    String? cvv,
    String? label,
    String? hexColor,
    bool? isDisposable,
    bool? isActive,
    bool? isGhostCard,
    DateTime? destructionDate,
    String? merchantLock,
    double? maxTransactionLimit,
    int? anonymityScore,
    String? cardHolderName,
    CardDesign? design,
    CardNetwork? network,
  }) {
    return VirtualCardEntity(
      id: id ?? this.id,
      cardNumber: cardNumber ?? this.cardNumber,
      expiryDate: expiryDate ?? this.expiryDate,
      cvv: cvv ?? this.cvv,
      label: label ?? this.label,
      hexColor: hexColor ?? this.hexColor,
      isDisposable: isDisposable ?? this.isDisposable,
      isActive: isActive ?? this.isActive,
      isGhostCard: isGhostCard ?? this.isGhostCard,
      destructionDate: destructionDate ?? this.destructionDate,
      merchantLock: merchantLock ?? this.merchantLock,
      maxTransactionLimit: maxTransactionLimit ?? this.maxTransactionLimit,
      anonymityScore: anonymityScore ?? this.anonymityScore,
      cardHolderName: cardHolderName ?? this.cardHolderName,
      design: design ?? this.design,
      network: network ?? this.network,
    );
  }

  @override
  List<Object?> get props => [
        id,
        cardNumber,
        expiryDate,
        cvv,
        label,
        hexColor,
        isDisposable,
        isActive,
        isGhostCard,
        destructionDate,
        merchantLock,
        maxTransactionLimit,
        anonymityScore,
        cardHolderName,
        design,
        network
      ];
}
