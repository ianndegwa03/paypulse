import 'package:paypulse/data/models/investment_model.dart';
import 'package:paypulse/domain/entities/enums.dart';

abstract class InvestmentDataSource {
  Future<List<InvestmentModel>> getInvestments();
  Future<void> invest(String symbol, double amount);
  Future<void> sell(String investmentId, double amount);
}

class InvestmentDataSourceImpl implements InvestmentDataSource {
  @override
  Future<List<InvestmentModel>> getInvestments() async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 800));
    return [
      InvestmentModel(
        id: '1',
        name: 'Apple Inc.',
        symbol: 'AAPL',
        amount: 1500.0,
        currency: CurrencyType.USD,
        currentValue: 1650.0,
        profitLoss: 150.0,
        profitLossPercentage: 10.0,
        purchaseDate: DateTime.now().subtract(const Duration(days: 30)),
      ),
      InvestmentModel(
        id: '2',
        name: 'Bitcoin',
        symbol: 'BTC',
        amount: 5000.0,
        currency: CurrencyType.USD,
        currentValue: 4800.0,
        profitLoss: -200.0,
        profitLossPercentage: -4.0,
        purchaseDate: DateTime.now().subtract(const Duration(days: 10)),
      ),
    ];
  }

  @override
  Future<void> invest(String symbol, double amount) async {
    await Future.delayed(const Duration(milliseconds: 1000));
  }

  @override
  Future<void> sell(String investmentId, double amount) async {
    await Future.delayed(const Duration(milliseconds: 1000));
  }
}
