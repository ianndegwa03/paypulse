import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paypulse/domain/entities/budget_entity.dart';
import 'package:paypulse/app/features/wallet/presentation/state/wallet_providers.dart';
import 'package:paypulse/domain/entities/enums.dart';

class BudgetState {
  final List<Budget> budgets;
  final bool isLoading;

  BudgetState({
    this.budgets = const [],
    this.isLoading = false,
  });

  BudgetState copyWith({
    List<Budget>? budgets,
    bool? isLoading,
  }) {
    return BudgetState(
      budgets: budgets ?? this.budgets,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class BudgetNotifier extends StateNotifier<BudgetState> {
  final Ref _ref;

  BudgetNotifier(this._ref) : super(BudgetState()) {
    _initMockBudgets();
  }

  void _initMockBudgets() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    state = state.copyWith(
      budgets: [
        Budget(
          id: '1',
          userId: 'user1',
          categoryId: 'cat_food',
          limitAmount: 500.0,
          currency: 'USD',
          startDate: startOfMonth,
          endDate: endOfMonth,
        ),
        Budget(
          id: '2',
          userId: 'user1',
          categoryId: 'cat_transport',
          limitAmount: 200.0,
          currency: 'USD',
          startDate: startOfMonth,
          endDate: endOfMonth,
        ),
        Budget(
          id: '3',
          userId: 'user1',
          categoryId: 'cat_entertainment',
          limitAmount: 150.0,
          currency: 'USD',
          startDate: startOfMonth,
          endDate: endOfMonth,
        ),
      ],
    );
    _updateSpentAmounts();
  }

  void _updateSpentAmounts() {
    final walletState = _ref.watch(walletStateProvider);
    final transactions = walletState.transactions;

    final updatedBudgets = state.budgets.map((budget) {
      double spent = 0;
      if (budget.categoryId == null) {
        spent = transactions
            .where((tx) => tx.type == TransactionType.debit)
            .fold(0, (sum, tx) => sum + tx.amount);
      } else {
        // Simple mapping for now since category IDs might mismatch
        // In a real app, we'd use the actual category_id
        spent = transactions
            .where((tx) =>
                tx.type == TransactionType.debit &&
                tx.description
                    .toLowerCase()
                    .contains(_getCategoryKeyword(budget.categoryId!)))
            .fold(0, (sum, tx) => sum + tx.amount);
      }
      return budget.copyWith(currentSpent: spent);
    }).toList();

    state = state.copyWith(budgets: updatedBudgets);
  }

  String _getCategoryKeyword(String categoryId) {
    if (categoryId.contains('food')) return 'food';
    if (categoryId.contains('transport')) return 'uber';
    if (categoryId.contains('entertainment')) return 'netflix';
    return '';
  }
}

final budgetProvider =
    StateNotifierProvider<BudgetNotifier, BudgetState>((ref) {
  return BudgetNotifier(ref);
});
