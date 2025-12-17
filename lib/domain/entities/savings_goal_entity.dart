import 'package:equatable/equatable.dart';
import 'package:paypulse/domain/entities/enums.dart';

class SavingsGoalEntity extends Equatable {
  final String id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final CurrencyType currency;
  final DateTime deadline;
  final String? imageUrl;

  const SavingsGoalEntity({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.currency,
    required this.deadline,
    this.imageUrl,
  });

  double get progressPercentage {
    if (targetAmount <= 0) return 0.0;
    return (currentAmount / targetAmount).clamp(0.0, 1.0);
  }

  @override
  List<Object?> get props => [
        id,
        name,
        targetAmount,
        currentAmount,
        currency,
        deadline,
        imageUrl,
      ];
}
