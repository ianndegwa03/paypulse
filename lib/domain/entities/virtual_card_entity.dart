import 'package:equatable/equatable.dart';

class VirtualCardEntity extends Equatable {
  final String id;
  final String cardNumber;
  final String expiryDate;
  final String cvv;
  final String label;
  final String hexColor;
  final bool isDisposable;
  final bool isActive;
  final bool isGhostCard;
  final DateTime? destructionDate;
  final String? merchantLock;
  final double? maxTransactionLimit;
  final int anonymityScore; // 0-100

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
  });

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
      ];

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
    );
  }
}
