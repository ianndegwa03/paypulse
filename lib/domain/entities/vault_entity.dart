import 'package:equatable/equatable.dart';

class VaultEntity extends Equatable {
  final String id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final String emoji;
  final String category;

  const VaultEntity({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.emoji,
    this.category = 'Goal',
  });

  double get progress =>
      targetAmount > 0 ? (currentAmount / targetAmount).clamp(0.0, 1.0) : 0.0;

  @override
  List<Object?> get props =>
      [id, name, targetAmount, currentAmount, emoji, category];

  VaultEntity copyWith({
    String? id,
    String? name,
    double? targetAmount,
    double? currentAmount,
    String? emoji,
    String? category,
  }) {
    return VaultEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      emoji: emoji ?? this.emoji,
      category: category ?? this.category,
    );
  }
}
