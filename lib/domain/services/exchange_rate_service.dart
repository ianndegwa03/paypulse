import 'package:paypulse/domain/entities/enums.dart';

class ExchangeRateResult {
  final Map<CurrencyType, double> bestRates;
  final Map<CurrencyType, String> bestProviders;
  final DateTime timestamp;

  ExchangeRateResult({
    required this.bestRates,
    required this.bestProviders,
    required this.timestamp,
  });
}

abstract class ExchangeRateService {
  /// Get all rates
  Future<ExchangeRateResult> getAllRates();

  /// Convert amount from one currency to another
  Future<double> convert(double amount, String fromCurrency, String toCurrency);

  /// Get live exchange rate
  Future<double> getRate(String fromCurrency, String toCurrency);
}
