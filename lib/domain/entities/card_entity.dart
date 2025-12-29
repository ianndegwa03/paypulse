import 'package:equatable/equatable.dart';
import 'package:paypulse/domain/entities/enums.dart';

class CardEntity extends Equatable {
  final String id;
  final String userId;
  final String lastFour;
  final String expiryDate;
  final String cardHolderName;
  final CardType type;
  final bool isDefault;

  const CardEntity({
    required this.id,
    required this.userId,
    required this.lastFour,
    required this.expiryDate,
    required this.cardHolderName,
    required this.type,
    this.isDefault = false,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        lastFour,
        expiryDate,
        cardHolderName,
        type,
        isDefault,
      ];

  CardEntity copyWith({
    String? id,
    String? userId,
    String? lastFour,
    String? expiryDate,
    String? cardHolderName,
    CardType? type,
    bool? isDefault,
  }) {
    return CardEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      lastFour: lastFour ?? this.lastFour,
      expiryDate: expiryDate ?? this.expiryDate,
      cardHolderName: cardHolderName ?? this.cardHolderName,
      type: type ?? this.type,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
