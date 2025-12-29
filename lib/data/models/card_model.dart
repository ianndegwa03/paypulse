import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paypulse/domain/entities/card_entity.dart';
import 'package:paypulse/domain/entities/enums.dart';

class CardModel extends CardEntity {
  factory CardModel.fromEntity(CardEntity entity) {
    return CardModel(
      id: entity.id,
      userId: entity.userId,
      lastFour: entity.lastFour,
      expiryDate: entity.expiryDate,
      cardHolderName: entity.cardHolderName,
      type: entity.type,
      isDefault: entity.isDefault,
    );
  }

  const CardModel({
    required super.id,
    required super.userId,
    required super.lastFour,
    required super.expiryDate,
    required super.cardHolderName,
    required super.type,
    super.isDefault,
  });

  factory CardModel.fromSnapshot(DocumentSnapshot snap) {
    return CardModel.fromMap(snap.id, snap.data() as Map<String, dynamic>);
  }

  factory CardModel.fromMap(String id, Map<String, dynamic> data) {
    return CardModel(
      id: id,
      userId: data['userId'] ?? '',
      lastFour: data['lastFour'] ?? '',
      expiryDate: data['expiryDate'] ?? '',
      cardHolderName: data['cardHolderName'] ?? '',
      type: CardType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => CardType.other,
      ),
      isDefault: data['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toDocument() {
    return {
      'userId': userId,
      'lastFour': lastFour,
      'expiryDate': expiryDate,
      'cardHolderName': cardHolderName,
      'type': type.name,
      'isDefault': isDefault,
    };
  }
}
