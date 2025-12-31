import 'package:fl_chart/fl_chart.dart';
import 'package:paypulse/domain/entities/enums.dart';
import 'package:paypulse/domain/entities/transaction_entity.dart';
import 'package:paypulse/domain/use_cases/transaction/get_transactions_use_case.dart';
import 'package:paypulse/domain/services/exchange_rate_service.dart';

class AnalyticsService {
  final GetTransactionsUseCase _getTransactionsUseCase;

  AnalyticsService({
    required GetTransactionsUseCase getTransactionsUseCase,
    required ExchangeRateService exchangeRateService,
  }) : _getTransactionsUseCase = getTransactionsUseCase;

  Future<List<FlSpot>> getIncomeData() async {
    final result = await _getTransactionsUseCase.execute(limit: 100);
    return result.fold(
      (failure) => [],
      (transactions) => _processData(transactions, TransactionType.credit),
    );
  }

  Future<List<FlSpot>> getExpenseData() async {
    final result = await _getTransactionsUseCase.execute(limit: 100);
    return result.fold(
      (failure) => [],
      (transactions) => _processData(transactions, TransactionType.debit),
    );
  }

  Future<Map<String, double>> getSpendingCategories() async {
    final result = await _getTransactionsUseCase.execute(limit: 100);
    return result.fold(
      (failure) => {},
      (transactions) {
        final Map<String, double> categories = {};
        for (var tx in transactions) {
          if (tx.type == TransactionType.debit) {
            final cat = tx.categoryId.isEmpty ? 'General' : tx.categoryId;
            categories[cat] = (categories[cat] ?? 0) + tx.amount.abs();
          }
        }
        return categories;
      },
    );
  }

  List<FlSpot> _processData(
      List<Transaction> transactions, TransactionType type) {
    // Map Month -> Total Amount
    final Map<int, double> monthlyTotals = {};
    final now = DateTime.now();

    for (var tx in transactions) {
      if (tx.type == type) {
        // Only consider last 6 months
        final monthsAgo =
            (now.year - tx.date.year) * 12 + now.month - tx.date.month;
        if (monthsAgo >= 0 && monthsAgo < 6) {
          final monthIndex = 6 - monthsAgo; // 1 = 5 months ago, 6 = this month
          monthlyTotals[monthIndex] =
              (monthlyTotals[monthIndex] ?? 0) + tx.amount.abs();
        }
      }
    }

    final List<FlSpot> spots = [];
    for (int i = 1; i <= 6; i++) {
      spots.add(FlSpot(i.toDouble(), monthlyTotals[i] ?? 0));
    }
    return spots;
  }
}
