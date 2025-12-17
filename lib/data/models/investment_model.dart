import 'package:paypulse/domain/entities/investment_entity.dart';
import 'package:paypulse/domain/entities/enums.dart';

class InvestmentModel extends InvestmentEntity {
  const InvestmentModel({
    required super.id,
    required super.name,
    required super.symbol,
    required super.amount,
    required super.currency,
    required super.currentValue,
    required super.profitLoss,
    required super.profitLossPercentage,
    required super.purchaseDate,
  });

  factory InvestmentModel.fromJson(Map<String, dynamic> json) {
    return InvestmentModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      symbol: json['symbol'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: CurrencyType.values.firstWhere(
        (e) => e.name == (json['currency'] as String? ?? 'USD'),
        orElse: () => CurrencyType.USD,
      ),
      currentValue: (json['current_value'] as num?)?.toDouble() ?? 0.0,
      profitLoss: (json['profit_loss'] as num?)?.toDouble() ?? 0.0,
      profitLossPercentage:
          (json['profit_loss_percentage'] as num?)?.toDouble() ?? 0.0,
      purchaseDate: json['purchase_date'] != null
          ? DateTime.parse(json['purchase_date'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'symbol': symbol,
      'amount': amount,
      'currency': currency.name,
      'current_value': currentValue,
      'profit_loss': profitLoss,
      'profit_loss_percentage': profitLossPercentage,
      'purchase_date': purchaseDate.toIso8601String(),
    };
  }
}
