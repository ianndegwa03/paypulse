import 'package:equatable/equatable.dart';

enum BudgetPeriod { monthly, weekly, yearly }

class Budget extends Equatable {
  final String id;
  final String userId;
  final String? categoryId; // Null means overall budget
  final double limitAmount;
  final double currentSpent;
  final String currency;
  final BudgetPeriod period;
  final DateTime startDate;
  final DateTime endDate;

  const Budget({
    required this.id,
    required this.userId,
    this.categoryId,
    required this.limitAmount,
    this.currentSpent = 0.0,
    required this.currency,
    this.period = BudgetPeriod.monthly,
    required this.startDate,
    required this.endDate,
  });

  double get progress => limitAmount == 0 ? 0 : currentSpent / limitAmount;
  bool get isOverBudget => currentSpent > limitAmount;

  Budget copyWith({
    String? id,
    String? userId,
    String? categoryId,
    double? limitAmount,
    double? currentSpent,
    String? currency,
    BudgetPeriod? period,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return Budget(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      categoryId: categoryId ?? this.categoryId,
      limitAmount: limitAmount ?? this.limitAmount,
      currentSpent: currentSpent ?? this.currentSpent,
      currency: currency ?? this.currency,
      period: period ?? this.period,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        categoryId,
        limitAmount,
        currentSpent,
        currency,
        period,
        startDate,
        endDate,
      ];
}
