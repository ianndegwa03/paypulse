import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:paypulse/core/errors/failures.dart';

class CurrencyConversionUseCase {
  CurrencyConversionUseCase();

  /// Uses exchangerate.host for reliable, no-key currency conversion.
  Future<Either<Failure, double>> execute({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
  }) async {
    if (fromCurrency == toCurrency) return Right(amount);

    try {
      final uri = Uri.parse(
          'https://api.exchangerate.host/convert?from=${Uri.encodeComponent(fromCurrency)}&to=${Uri.encodeComponent(toCurrency)}&amount=${amount.toString()}');

      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) {
        return Left(NetworkFailure(
            message: 'Failed to fetch exchange rate: ${response.statusCode}'));
      }

      final body = json.decode(response.body) as Map<String, dynamic>;
      if (body['result'] == null) {
        return const Left(NetworkFailure(message: 'Unexpected rates response'));
      }

      final converted = (body['result'] as num).toDouble();
      return Right(converted);
    } catch (e) {
      return Left(NetworkFailure(message: 'Conversion failed: $e'));
    }
  }
}
