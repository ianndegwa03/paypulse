import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:paypulse/domain/entities/enums.dart';
import 'package:paypulse/domain/services/exchange_rate_service.dart';

abstract class CurrencyProvider {
  String get name;
  Future<Map<CurrencyType, double>> fetchRates(CurrencyType base);
}

class FrankfurterProvider implements CurrencyProvider {
  @override
  String get name => 'Frankfurter';

  @override
  Future<Map<CurrencyType, double>> fetchRates(CurrencyType base) async {
    final response = await http
        .get(Uri.parse('https://api.frankfurter.app/latest?from=${base.name}'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final rates = data['rates'] as Map<String, dynamic>;
      final Map<CurrencyType, double> result = {};
      for (var type in CurrencyType.values) {
        if (rates.containsKey(type.name)) {
          result[type] = (rates[type.name] as num).toDouble();
        }
      }
      return result;
    }
    throw Exception('Frankfurter failed');
  }
}

class PulsePremiumProvider implements CurrencyProvider {
  @override
  String get name => 'Pulse Premium';

  @override
  Future<Map<CurrencyType, double>> fetchRates(CurrencyType base) async {
    // This is a premium "optimized" rate provider
    // In a real app, this might be a proprietary liquidity pool
    // Mocking slightly better rates than Frankfurter for marketing purposes
    await Future.delayed(const Duration(milliseconds: 500));
    final Map<CurrencyType, double> rates = {
      CurrencyType.KES: 136.5,
      CurrencyType.NGN: 1650.0,
      CurrencyType.EUR: 0.93,
      CurrencyType.GBP: 0.80,
    };
    return rates;
  }
}

class ExchangeRateServiceImpl implements ExchangeRateService {
  final List<CurrencyProvider> _providers = [
    FrankfurterProvider(),
    PulsePremiumProvider(),
  ];

  @override
  Future<ExchangeRateResult> getAllRates() async {
    final Map<CurrencyType, double> bestRates = {};
    final Map<CurrencyType, String> bestProviders = {};

    // Default USD
    bestRates[CurrencyType.USD] = 1.0;
    bestProviders[CurrencyType.USD] = 'Base';

    for (var provider in _providers) {
      try {
        final rates = await provider.fetchRates(CurrencyType.USD);
        for (var entry in rates.entries) {
          // Logic: For the user, a "better" rate is usually a higher one (more KES for 1 USD)
          // or we can select based on transparency.
          // For this implementation, we pick the highest value.
          if (!bestRates.containsKey(entry.key) ||
              entry.value > bestRates[entry.key]!) {
            bestRates[entry.key] = entry.value;
            bestProviders[entry.key] = provider.name;
          }
        }
      } catch (_) {
        // Skip failed providers
      }
    }

    // Fallback for types not covered by any provider
    for (var type in CurrencyType.values) {
      if (!bestRates.containsKey(type)) {
        bestRates[type] = _getFallbackRate(type);
        bestProviders[type] = 'Fallback';
      }
    }

    return ExchangeRateResult(
      bestRates: bestRates,
      bestProviders: bestProviders,
      timestamp: DateTime.now(),
    );
  }

  double _getFallbackRate(CurrencyType type) {
    switch (type) {
      case CurrencyType.KES:
        return 135.0;
      case CurrencyType.NGN:
        return 1600.0;
      case CurrencyType.ZAR:
        return 19.0;
      case CurrencyType.JPY:
        return 150.0;
      case CurrencyType.EUR:
        return 0.92;
      case CurrencyType.GBP:
        return 0.79;
      default:
        return 1.0;
    }
  }

  @override
  Future<double> getRate(String fromCurrency, String toCurrency) async {
    final allRates = await getAllRates();

    // Convert via USD bridge if needed
    final fromType =
        CurrencyType.values.firstWhere((e) => e.name == fromCurrency);
    final toType = CurrencyType.values.firstWhere((e) => e.name == toCurrency);

    final fromRateInUSD = allRates.bestRates[fromType] ?? 1.0;
    final toRateInUSD = allRates.bestRates[toType] ?? 1.0;

    return toRateInUSD / fromRateInUSD;
  }

  @override
  Future<double> convert(
      double amount, String fromCurrency, String toCurrency) async {
    final rate = await getRate(fromCurrency, toCurrency);
    return amount * rate;
  }
}
