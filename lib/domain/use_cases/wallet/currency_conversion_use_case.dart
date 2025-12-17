import 'package:dartz/dartz.dart';
import 'package:paypulse/core/errors/failures.dart';

class CurrencyConversionUseCase {
  // Real implementation would inject a CurrencyService
  CurrencyConversionUseCase();

  Future<Either<Failure, double>> execute({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
  }) async {
    // Mock conversion for now as we don't have Rates API setup
    // Basic conversion logic implemented
    if (fromCurrency == toCurrency) return Right(amount);

    // Simple mock rates
    final rates = {
      'USD': 1.0,
      'EUR': 0.92,
      'GBP': 0.79,
      'KES': 130.0,
    };

    final fromRate = rates[fromCurrency] ?? 1.0;
    final toRate = rates[toCurrency] ?? 1.0;

    final result = (amount / fromRate) * toRate;
    return Right(result);
  }
}
