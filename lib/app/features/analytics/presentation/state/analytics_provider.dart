import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paypulse/app/di/injector.dart';
import 'package:paypulse/data/services/analytics_service.dart';
import 'package:paypulse/domain/use_cases/transaction/get_transactions_use_case.dart';
import 'package:paypulse/app/features/wallet/presentation/state/wallet_providers.dart';
import 'package:fl_chart/fl_chart.dart';

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService(
    getTransactionsUseCase: getIt<GetTransactionsUseCase>(),
    exchangeRateService: ref.watch(exchangeRateServiceProvider),
  );
});

class AnalyticsState {
  final List<FlSpot> incomeData;
  final List<FlSpot> expenseData;
  final Map<String, double> categories;
  final double totalIncome;
  final double totalExpense;
  final bool isLoading;

  AnalyticsState({
    required this.incomeData,
    required this.expenseData,
    required this.categories,
    required this.totalIncome,
    required this.totalExpense,
    required this.isLoading,
  });

  factory AnalyticsState.initial() => AnalyticsState(
        incomeData: [],
        expenseData: [],
        categories: {},
        totalIncome: 0.0,
        totalExpense: 0.0,
        isLoading: true,
      );

  AnalyticsState copyWith({
    List<FlSpot>? incomeData,
    List<FlSpot>? expenseData,
    Map<String, double>? categories,
    double? totalIncome,
    double? totalExpense,
    bool? isLoading,
  }) {
    return AnalyticsState(
      incomeData: incomeData ?? this.incomeData,
      expenseData: expenseData ?? this.expenseData,
      categories: categories ?? this.categories,
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpense: totalExpense ?? this.totalExpense,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AnalyticsNotifier extends StateNotifier<AnalyticsState> {
  final AnalyticsService _service;

  AnalyticsNotifier(this._service) : super(AnalyticsState.initial()) {
    loadData();
  }

  Future<void> loadData() async {
    state = state.copyWith(isLoading: true);
    final income = await _service.getIncomeData();
    final expense = await _service.getExpenseData();
    final categories = await _service.getSpendingCategories();

    // Sum last month data
    final totalIncome = income.isNotEmpty ? income.last.y : 0.0;
    final totalExpense = expense.isNotEmpty ? expense.last.y : 0.0;

    state = state.copyWith(
      incomeData: income,
      expenseData: expense,
      categories: categories,
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      isLoading: false,
    );
  }
}

final analyticsProvider =
    StateNotifierProvider<AnalyticsNotifier, AnalyticsState>((ref) {
  return AnalyticsNotifier(ref.watch(analyticsServiceProvider));
});
