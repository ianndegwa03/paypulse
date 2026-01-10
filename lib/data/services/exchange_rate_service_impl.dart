import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:paypulse/domain/entities/enums.dart';
import 'package:paypulse/domain/services/exchange_rate_service.dart';

abstract class CurrencyProvider {
  String get name;
  Future<Map<CurrencyType, double>> fetchRates(CurrencyType base);
}

/// Free API: ExchangeRate-API (1500 requests/month)
/// Docs: https://www.exchangerate-api.com/docs/free
class ExchangeRateAPIProvider implements CurrencyProvider {
  static const String _apiKey =
      '6f8b3c5d4e2a1f9b7c8d9e0f'; // FREE API KEY - replace with yours
  static const String _baseUrl = 'https://v6.exchangerate-api.com/v6';

  @override
  String get name => 'ExchangeRate-API';

  @override
  Future<Map<CurrencyType, double>> fetchRates(CurrencyType base) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/$_apiKey/latest/${base.name}'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Check if API request was successful
        if (data['result'] != 'success') {
          throw Exception(
              'ExchangeRate-API returned error: ${data['error-type']}');
        }

        final rates = data['conversion_rates'] as Map<String, dynamic>;
        final Map<CurrencyType, double> result = {};

        for (var type in CurrencyType.values) {
          if (rates.containsKey(type.name)) {
            result[type] = (rates[type.name] as num).toDouble();
          }
        }

        return result;
      }

      throw Exception('ExchangeRate-API HTTP ${response.statusCode}');
    } catch (e) {
      throw Exception('ExchangeRate-API failed: $e');
    }
  }
}

/// Frankfurter (European Central Bank) - Completely Free, No API Key
/// Docs: https://www.frankfurter.app/docs/
class FrankfurterProvider implements CurrencyProvider {
  @override
  String get name => 'Frankfurter';

  @override
  Future<Map<CurrencyType, double>> fetchRates(CurrencyType base) async {
    try {
      final response = await http
          .get(
            Uri.parse('https://api.frankfurter.app/latest?from=${base.name}'),
          )
          .timeout(const Duration(seconds: 10));

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

      throw Exception('Frankfurter HTTP ${response.statusCode}');
    } catch (e) {
      throw Exception('Frankfurter failed: $e');
    }
  }
}

class ExchangeRateServiceImpl implements ExchangeRateService {
  static const String _cacheBoxName = 'exchange_rates_cache';
  static const Duration _cacheDuration = Duration(hours: 6);

  final List<CurrencyProvider> _providers = [
    ExchangeRateAPIProvider(),
    FrankfurterProvider(),
  ];

  Box? _cacheBox;

  Future<void> _initCache() async {
    if (_cacheBox == null || !_cacheBox!.isOpen) {
      _cacheBox = await Hive.openBox(_cacheBoxName);
    }
  }

  @override
  Future<ExchangeRateResult> getAllRates() async {
    await _initCache();

    // Try to get from cache first
    final cached = await _getFromCache();
    if (cached != null) {
      return cached;
    }

    final Map<CurrencyType, double> bestRates = {};
    final Map<CurrencyType, String> bestProviders = {};

    // Default USD
    bestRates[CurrencyType.USD] = 1.0;
    bestProviders[CurrencyType.USD] = 'Base';

    // Fetch from all providers and select best rates
    for (var provider in _providers) {
      try {
        final rates = await provider.fetchRates(CurrencyType.USD);
        for (var entry in rates.entries) {
          // Select the highest rate (better for user converting TO local currency)
          if (!bestRates.containsKey(entry.key) ||
              entry.value > bestRates[entry.key]!) {
            bestRates[entry.key] = entry.value;
            bestProviders[entry.key] = provider.name;
          }
        }
      } catch (e) {
        print('Provider ${provider.name} failed: $e');
        // Continue with other providers
      }
    }

    // Fallback for missing currencies
    for (var type in CurrencyType.values) {
      if (!bestRates.containsKey(type)) {
        bestRates[type] = _getFallbackRate(type);
        bestProviders[type] = 'Fallback';
      }
    }

    final result = ExchangeRateResult(
      bestRates: bestRates,
      bestProviders: bestProviders,
      timestamp: DateTime.now(),
    );

    // Cache the result
    await _saveToCache(result);

    return result;
  }

  Future<ExchangeRateResult?> _getFromCache() async {
    try {
      final cacheData = _cacheBox?.get('rates');
      if (cacheData == null) return null;

      final Map<String, dynamic> data = Map<String, dynamic>.from(cacheData);
      final timestamp = DateTime.parse(data['timestamp']);

      // Check if cache is still valid
      if (DateTime.now().difference(timestamp) > _cacheDuration) {
        return null;
      }

      final bestRates = <CurrencyType, double>{};
      final bestProviders = <CurrencyType, String>{};

      final rates = Map<String, dynamic>.from(data['rates']);
      final providers = Map<String, dynamic>.from(data['providers']);

      for (var type in CurrencyType.values) {
        if (rates.containsKey(type.name)) {
          bestRates[type] = (rates[type.name] as num).toDouble();
          bestProviders[type] = providers[type.name] as String;
        }
      }

      return ExchangeRateResult(
        bestRates: bestRates,
        bestProviders: bestProviders,
        timestamp: timestamp,
      );
    } catch (e) {
      print('Cache read failed: $e');
      return null;
    }
  }

  Future<void> _saveToCache(ExchangeRateResult result) async {
    try {
      final ratesMap = <String, double>{};
      final providersMap = <String, String>{};

      result.bestRates.forEach((key, value) {
        ratesMap[key.name] = value;
      });

      result.bestProviders.forEach((key, value) {
        providersMap[key.name] = value;
      });

      await _cacheBox?.put('rates', {
        'rates': ratesMap,
        'providers': providersMap,
        'timestamp': result.timestamp.toIso8601String(),
      });
    } catch (e) {
      print('Cache write failed: $e');
    }
  }

  double _getFallbackRate(CurrencyType type) {
    // Conservative fallback rates (as of early 2024)
    switch (type) {
      case CurrencyType.KES:
        return 150.0; // Kenyan Shilling
      case CurrencyType.NGN:
        return 800.0; // Nigerian Naira
      case CurrencyType.ZAR:
        return 18.5; // South African Rand
      case CurrencyType.GHS:
        return 12.0; // Ghanaian Cedi
      case CurrencyType.TZS:
        return 2500.0; // Tanzanian Shilling
      case CurrencyType.UGX:
        return 3700.0; // Ugandan Shilling
      case CurrencyType.JPY:
        return 145.0; // Japanese Yen
      case CurrencyType.EUR:
        return 0.92; // Euro
      case CurrencyType.GBP:
        return 0.79; // British Pound
      case CurrencyType.CNY:
        return 7.2; // Chinese Yuan
      case CurrencyType.INR:
        return 83.0; // Indian Rupee
      default:
        return 1.0;
    }
  }

  @override
  Future<double> getRate(String fromCurrency, String toCurrency) async {
    final allRates = await getAllRates();

    // Convert via USD bridge
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

  /// Clear cache manually (useful for refresh button)
  Future<void> clearCache() async {
    await _initCache();
    await _cacheBox?.clear();
  }

  /// Get cache age
  Future<Duration?> getCacheAge() async {
    await _initCache();
    try {
      final cacheData = _cacheBox?.get('rates');
      if (cacheData == null) return null;

      final timestamp = DateTime.parse(cacheData['timestamp']);
      return DateTime.now().difference(timestamp);
    } catch (e) {
      return null;
    }
  }
}
