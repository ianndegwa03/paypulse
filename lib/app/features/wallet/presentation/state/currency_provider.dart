import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paypulse/domain/entities/enums.dart';
import 'package:paypulse/core/services/location/location_service.dart';
import 'package:paypulse/core/services/exchange_rate_service.dart';

/// Currency metadata for display
class CurrencyMetadata {
  final String symbol;
  final String name;
  final String flag;

  CurrencyMetadata(this.symbol, this.name, {this.flag = ''});
}

/// Get metadata for a currency type
CurrencyMetadata getCurrencyMetadata(CurrencyType type) {
  switch (type) {
    case CurrencyType.USD:
      return CurrencyMetadata('\$', 'US Dollar', flag: '🇺🇸');
    case CurrencyType.EUR:
      return CurrencyMetadata('€', 'Euro', flag: '🇪🇺');
    case CurrencyType.GBP:
      return CurrencyMetadata('£', 'British Pound', flag: '🇬🇧');
    case CurrencyType.JPY:
      return CurrencyMetadata('¥', 'Japanese Yen', flag: '🇯🇵');
    case CurrencyType.KES:
      return CurrencyMetadata('KSh', 'Kenya Shilling', flag: '🇰🇪');
    case CurrencyType.NGN:
      return CurrencyMetadata('₦', 'Nigerian Naira', flag: '🇳🇬');
    case CurrencyType.ZAR:
      return CurrencyMetadata('R', 'South African Rand', flag: '🇿🇦');
    case CurrencyType.GHS:
      return CurrencyMetadata('₵', 'Ghanaian Cedi', flag: '🇬🇭');
    case CurrencyType.TZS:
      return CurrencyMetadata('TSh', 'Tanzanian Shilling', flag: '🇹🇿');
    case CurrencyType.UGX:
      return CurrencyMetadata('USh', 'Ugandan Shilling', flag: '🇺🇬');
    case CurrencyType.CNY:
      return CurrencyMetadata('¥', 'Chinese Yuan', flag: '🇨🇳');
    case CurrencyType.INR:
      return CurrencyMetadata('₹', 'Indian Rupee', flag: '🇮🇳');
  }
}

/// Enhanced currency state with multi-source rate tracking
class CurrencyState {
  final CurrencyType selectedCurrency;
  final Map<CurrencyType, double> exchangeRates;
  final Map<CurrencyType, String> bestProviders;
  final bool isLoading;
  final bool isStale;
  final DateTime? lastUpdated;
  final String? activeProvider;

  CurrencyState({
    required this.selectedCurrency,
    this.exchangeRates = const {
      CurrencyType.USD: 1.0,
      CurrencyType.EUR: 0.92,
      CurrencyType.GBP: 0.79,
      CurrencyType.JPY: 149.5,
      CurrencyType.KES: 154.0,
      CurrencyType.NGN: 1580.0,
      CurrencyType.ZAR: 18.5,
    },
    this.bestProviders = const {},
    this.isLoading = false,
    this.isStale = false,
    this.lastUpdated,
    this.activeProvider,
  });

  CurrencyState copyWith({
    CurrencyType? selectedCurrency,
    Map<CurrencyType, double>? exchangeRates,
    Map<CurrencyType, String>? bestProviders,
    bool? isLoading,
    bool? isStale,
    DateTime? lastUpdated,
    String? activeProvider,
  }) {
    return CurrencyState(
      selectedCurrency: selectedCurrency ?? this.selectedCurrency,
      exchangeRates: exchangeRates ?? this.exchangeRates,
      bestProviders: bestProviders ?? this.bestProviders,
      isLoading: isLoading ?? this.isLoading,
      isStale: isStale ?? this.isStale,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      activeProvider: activeProvider ?? this.activeProvider,
    );
  }

  /// Check if rates need refresh (older than 5 minutes)
  bool get needsRefresh {
    if (lastUpdated == null) return true;
    return DateTime.now().difference(lastUpdated!) > const Duration(minutes: 5);
  }

  /// Get rate between any two currencies (from -> to)
  double getRate(CurrencyType from, CurrencyType to) {
    final fromRate = exchangeRates[from] ?? 1.0;
    final toRate = exchangeRates[to] ?? 1.0;
    return toRate / fromRate;
  }
}

/// Enhanced currency notifier with multi-source rate fetching
class CurrencyNotifier extends StateNotifier<CurrencyState> {
  final LocationService _locationService;
  final ExchangeRateService _rateService;

  CurrencyNotifier(this._locationService, this._rateService)
      : super(CurrencyState(selectedCurrency: CurrencyType.USD)) {
    _initialize();
  }

  Future<void> _initialize() async {
    state = state.copyWith(isLoading: true);

    // Get user's location-based currency
    final location = await _locationService.getUserLocation();
    final countryCurrency = location['currency'] ?? 'USD';
    final defaultCurrency = CurrencyType.values.firstWhere(
      (e) => e.name == countryCurrency,
      orElse: () => CurrencyType.USD,
    );

    state = state.copyWith(selectedCurrency: defaultCurrency);
    await fetchRates();
  }

  /// Fetch best rates from multiple sources
  Future<void> fetchRates() async {
    if (state.isLoading && state.lastUpdated != null) return;

    state = state.copyWith(isLoading: true);

    try {
      final result = await _rateService.getAllRates();

      state = state.copyWith(
        exchangeRates: result.bestRates,
        bestProviders: result.bestProviders,
        isLoading: false,
        isStale: false,
        lastUpdated: result.timestamp,
        activeProvider: 'Multi-Source (Best)',
      );
    } catch (e) {
      // Keep existing rates but mark as stale
      state = state.copyWith(
        isLoading: false,
        isStale: true,
      );
    }
  }

  /// Force refresh rates
  Future<void> refreshRates() async {
    state = state.copyWith(isLoading: true);
    await fetchRates();
  }

  /// Set the selected currency
  void setCurrency(CurrencyType currency) {
    state = state.copyWith(selectedCurrency: currency);
  }

  /// Convert amount from USD to selected currency
  double convertFromUSD(double amount) {
    return amount * (state.exchangeRates[state.selectedCurrency] ?? 1.0);
  }

  /// Convert amount between any two currencies
  double convert(double amount, CurrencyType from, CurrencyType to) {
    final fromRate = state.exchangeRates[from] ?? 1.0;
    final toRate = state.exchangeRates[to] ?? 1.0;

    // Convert to USD first, then to target
    final inUSD = amount / fromRate;
    return inUSD * toRate;
  }

  /// Format amount with currency symbol
  String formatAmount(double amountUSD, {CurrencyType? currency}) {
    final targetCurrency = currency ?? state.selectedCurrency;
    final converted = amountUSD * (state.exchangeRates[targetCurrency] ?? 1.0);
    final meta = getCurrencyMetadata(targetCurrency);
    return '${meta.symbol}${_formatNumber(converted)}';
  }

  /// Get the best provider for a specific currency
  String? getBestProvider(CurrencyType currency) {
    return state.bestProviders[currency];
  }

  /// Format number with proper separators
  String _formatNumber(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(2)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(2)}K';
    } else if (value >= 1) {
      return value.toStringAsFixed(2);
    } else {
      return value.toStringAsFixed(4);
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// PROVIDERS
// ═══════════════════════════════════════════════════════════════════════════

final locationServiceProvider = Provider((ref) => LocationService());

final currencyProvider = StateNotifierProvider<CurrencyNotifier, CurrencyState>(
  (ref) {
    final locationService = ref.watch(locationServiceProvider);
    final rateService = ref.watch(exchangeRateServiceProvider);
    return CurrencyNotifier(locationService, rateService);
  },
);

/// Stream of currency state that auto-refreshes
final autoRefreshCurrencyProvider = StreamProvider<CurrencyState>((ref) async* {
  final notifier = ref.watch(currencyProvider.notifier);

  // Emit current state
  yield ref.read(currencyProvider);

  // Refresh every 5 minutes
  await for (final _ in Stream.periodic(const Duration(minutes: 5))) {
    await notifier.refreshRates();
    yield ref.read(currencyProvider);
  }
});
