import 'package:paypulse/domain/entities/vault_entity.dart';

class VaultModel extends VaultEntity {
  const VaultModel({
    required super.id,
    required super.name,
    required super.targetAmount,
    required super.currentAmount,
    required super.emoji,
    super.category,
  });

  factory VaultModel.fromEntity(VaultEntity entity) {
    return VaultModel(
      id: entity.id,
      name: entity.name,
      targetAmount: entity.targetAmount,
      currentAmount: entity.currentAmount,
      emoji: entity.emoji,
      category: entity.category,
    );
  }

  factory VaultModel.fromMap(String id, Map<String, dynamic> map) {
    return VaultModel(
      id: id,
      name: map['name'] ?? '',
      targetAmount: (map['targetAmount'] as num?)?.toDouble() ?? 0.0,
      currentAmount: (map['currentAmount'] as num?)?.toDouble() ?? 0.0,
      emoji: map['emoji'] ?? '💰',
      category: map['category'] ?? 'Goal',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'emoji': emoji,
      'category': category,
    };
  }
}
