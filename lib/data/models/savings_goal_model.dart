import 'package:paypulse/domain/entities/savings_goal_entity.dart';
import 'package:paypulse/domain/entities/enums.dart';

class SavingsGoalModel extends SavingsGoalEntity {
  const SavingsGoalModel({
    required super.id,
    required super.name,
    required super.targetAmount,
    required super.currentAmount,
    required super.currency,
    required super.deadline,
    super.imageUrl,
  });

  factory SavingsGoalModel.fromJson(Map<String, dynamic> json) {
    return SavingsGoalModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      targetAmount: (json['target_amount'] as num?)?.toDouble() ?? 0.0,
      currentAmount: (json['current_amount'] as num?)?.toDouble() ?? 0.0,
      currency: CurrencyType.values.firstWhere(
        (e) => e.name == (json['currency'] as String? ?? 'USD'),
        orElse: () => CurrencyType.USD,
      ),
      deadline: json['deadline'] != null
          ? DateTime.parse(json['deadline'] as String)
          : DateTime.now().add(const Duration(days: 365)),
      imageUrl: json['image_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'target_amount': targetAmount,
      'current_amount': currentAmount,
      'currency': currency.name,
      'deadline': deadline.toIso8601String(),
      'image_url': imageUrl,
    };
  }
}
