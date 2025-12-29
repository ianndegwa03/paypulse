import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:paypulse/domain/entities/enums.dart';

/// Represents a rate from a specific provider
class ProviderRate {
  final String providerName;
  final double rate;
  final DateTime timestamp;
  final bool isReliable;

  ProviderRate({
    required this.providerName,
    required this.rate,
    required this.timestamp,
    this.isReliable = true,
  });

  @override
  String toString() => '$providerName: $rate';
}

/// Comparison result showing all available rates
class RateComparison {
  final CurrencyType from;
  final CurrencyType to;
  final List<ProviderRate> rates;
  final ProviderRate? bestRate;
  final double? savings; // Potential savings using best rate vs average

  RateComparison({
    required this.from,
    required this.to,
    required this.rates,
  })  : bestRate = rates.isNotEmpty
            ? rates.reduce((a, b) => a.rate > b.rate ? a : b)
            : null,
        savings = rates.length >= 2
            ? ((rates.reduce((a, b) => a.rate > b.rate ? a : b).rate -
                    (rates.map((r) => r.rate).reduce((a, b) => a + b) /
                        rates.length)) /
                (rates.map((r) => r.rate).reduce((a, b) => a + b) /
                    rates.length) *
                100)
            : null;
}

/// Aggregated exchange rate result
class ExchangeRateResult {
  final Map<CurrencyType, Map<String, double>> ratesByProvider;
  final Map<CurrencyType, double> bestRates;
  final Map<CurrencyType, String> bestProviders;
  final DateTime timestamp;
  final bool isStale;

  ExchangeRateResult({
    required this.ratesByProvider,
    required this.bestRates,
    required this.bestProviders,
    required this.timestamp,
    this.isStale = false,
  });
}

/// Service to fetch exchange rates from multiple reliable sources
/// Aggregates rates and finds the best ones for profit optimization
class ExchangeRateService {
  static const String _exchangeRateApi =
      'https://api.exchangerate-api.com/v4/latest';
  static const String _frankfurterApi = 'https://api.frankfurter.app/latest';
  static const String _floatRatesApi =
      'https://www.floatrates.com/daily/usd.json';

  final http.Client _client;

  ExchangeRateService({http.Client? client})
      : _client = client ?? http.Client();

  /// Fetch rates from all providers concurrently
  Future<ExchangeRateResult> getAllRates({
    String baseCurrency = 'USD',
  }) async {
    final results = await Future.wait([
      _fetchExchangeRateApi(baseCurrency),
      _fetchFrankfurterApi(baseCurrency),
      _fetchFloatRatesApi(baseCurrency),
    ]);

    final Map<CurrencyType, Map<String, double>> ratesByProvider = {};
    final Map<CurrencyType, double> bestRates = {};
    final Map<CurrencyType, String> bestProviders = {};

    // Aggregate results
    for (int i = 0; i < results.length; i++) {
      final providerName = ['ExchangeRate-API', 'Frankfurter', 'FloatRates'][i];
      final rates = results[i];

      for (var entry in rates.entries) {
        ratesByProvider[entry.key] ??= {};
        ratesByProvider[entry.key]![providerName] = entry.value;

        // Track best rate
        if (!bestRates.containsKey(entry.key) ||
            entry.value > bestRates[entry.key]!) {
          bestRates[entry.key] = entry.value;
          bestProviders[entry.key] = providerName;
        }
      }
    }

    return ExchangeRateResult(
      ratesByProvider: ratesByProvider,
      bestRates: bestRates,
      bestProviders: bestProviders,
      timestamp: DateTime.now(),
    );
  }

  /// Compare rates for a specific currency pair
  Future<RateComparison> compareRates(
    CurrencyType from,
    CurrencyType to,
  ) async {
    final allRates = await getAllRates(baseCurrency: from.name);
    final rates = <ProviderRate>[];

    if (allRates.ratesByProvider.containsKey(to)) {
      for (var entry in allRates.ratesByProvider[to]!.entries) {
        rates.add(ProviderRate(
          providerName: entry.key,
          rate: entry.value,
          timestamp: allRates.timestamp,
        ));
      }
    }

    return RateComparison(from: from, to: to, rates: rates);
  }

  /// Get the best rate for sending money (highest rate = more for receiver)
  Future<ProviderRate?> getBestRateForSending(
    CurrencyType from,
    CurrencyType to,
    double amount,
  ) async {
    final comparison = await compareRates(from, to);
    return comparison.bestRate;
  }

  /// Calculate potential savings using best rate vs worst
  Future<double> calculatePotentialSavings(
    CurrencyType from,
    CurrencyType to,
    double amount,
  ) async {
    final comparison = await compareRates(from, to);
    if (comparison.rates.length < 2) return 0;

    final bestRate =
        comparison.rates.reduce((a, b) => a.rate > b.rate ? a : b).rate;
    final worstRate =
        comparison.rates.reduce((a, b) => a.rate < b.rate ? a : b).rate;

    return amount * (bestRate - worstRate);
  }

  /// Fetch from primary API: exchangerate-api.com
  Future<Map<CurrencyType, double>> _fetchExchangeRateApi(
      String baseCurrency) async {
    try {
      final response =
          await _client.get(Uri.parse('$_exchangeRateApi/$baseCurrency'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final Map<String, dynamic> rates = data['rates'];
        return _parseRates(rates);
      }
    } catch (e) {
      // Silently fail, other providers will provide data
    }
    return {};
  }

  /// Fetch from Frankfurter API (ECB data)
  Future<Map<CurrencyType, double>> _fetchFrankfurterApi(
      String baseCurrency) async {
    try {
      final response =
          await _client.get(Uri.parse('$_frankfurterApi?from=$baseCurrency'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final Map<String, dynamic> rates = data['rates'];
        return _parseRates(rates);
      }
    } catch (e) {
      // Silently fail
    }
    return {};
  }

  /// Fetch from FloatRates API
  Future<Map<CurrencyType, double>> _fetchFloatRatesApi(
      String baseCurrency) async {
    try {
      // FloatRates uses lowercase currency codes
      final response = await _client.get(Uri.parse(
          _floatRatesApi.replaceAll('usd', baseCurrency.toLowerCase())));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final Map<CurrencyType, double> rates = {};

        for (var type in CurrencyType.values) {
          final code = type.name.toLowerCase();
          if (data.containsKey(code)) {
            rates[type] = (data[code]['rate'] as num).toDouble();
          }
        }
        return rates;
      }
    } catch (e) {
      // Silently fail
    }
    return {};
  }

  /// Parse rate map to CurrencyType map
  Map<CurrencyType, double> _parseRates(Map<String, dynamic> rates) {
    final result = <CurrencyType, double>{};
    for (var type in CurrencyType.values) {
      if (rates.containsKey(type.name)) {
        result[type] = (rates[type.name] as num).toDouble();
      }
    }
    return result;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// RIVERPOD PROVIDERS
// ═══════════════════════════════════════════════════════════════════════════

/// Service provider
final exchangeRateServiceProvider = Provider((ref) => ExchangeRateService());

/// All aggregated rates
final aggregatedRatesProvider = FutureProvider<ExchangeRateResult>((ref) async {
  final service = ref.watch(exchangeRateServiceProvider);
  return service.getAllRates();
});

/// Auto-refreshing rates (every 5 minutes)
final autoRefreshRatesProvider =
    StreamProvider<ExchangeRateResult>((ref) async* {
  final service = ref.watch(exchangeRateServiceProvider);

  // Initial fetch
  yield await service.getAllRates();

  // Periodic refresh
  await for (final _ in Stream.periodic(const Duration(minutes: 5))) {
    yield await service.getAllRates();
  }
});

/// Rate comparison for specific pair
final rateComparisonProvider =
    FutureProvider.family<RateComparison, (CurrencyType, CurrencyType)>(
        (ref, pair) async {
  final service = ref.watch(exchangeRateServiceProvider);
  return service.compareRates(pair.$1, pair.$2);
});

/// Best rate for sending money
final bestRateProvider =
    FutureProvider.family<ProviderRate?, (CurrencyType, CurrencyType, double)>(
        (ref, params) async {
  final service = ref.watch(exchangeRateServiceProvider);
  return service.getBestRateForSending(params.$1, params.$2, params.$3);
});
