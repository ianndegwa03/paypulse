import 'package:equatable/equatable.dart';
import 'package:paypulse/domain/entities/enums.dart';

class InvestmentEntity extends Equatable {
  final String id;
  final String name;
  final String symbol;
  final double amount;
  final CurrencyType currency;
  final double currentValue;
  final double profitLoss;
  final double profitLossPercentage;
  final DateTime purchaseDate;

  const InvestmentEntity({
    required this.id,
    required this.name,
    required this.symbol,
    required this.amount,
    required this.currency,
    required this.currentValue,
    required this.profitLoss,
    required this.profitLossPercentage,
    required this.purchaseDate,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        symbol,
        amount,
        currency,
        currentValue,
        profitLoss,
        profitLossPercentage,
        purchaseDate,
      ];
}
