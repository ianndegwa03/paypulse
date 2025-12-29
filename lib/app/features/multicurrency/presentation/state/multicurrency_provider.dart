import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paypulse/domain/entities/enums.dart';

class MultiCurrencyState {
  final Map<CurrencyType, double> balances;
  final Map<String, double> exchangeRates; // Base USD
  final bool isLoading;

  MultiCurrencyState({
    this.balances = const {},
    this.exchangeRates = const {},
    this.isLoading = false,
  });

  MultiCurrencyState copyWith({
    Map<CurrencyType, double>? balances,
    Map<String, double>? exchangeRates,
    bool? isLoading,
  }) {
    return MultiCurrencyState(
      balances: balances ?? this.balances,
      exchangeRates: exchangeRates ?? this.exchangeRates,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class MultiCurrencyNotifier extends StateNotifier<MultiCurrencyState> {
  MultiCurrencyNotifier() : super(MultiCurrencyState()) {
    _initBalances();
    _fetchRates();
  }

  void _initBalances() {
    state = state.copyWith(
      balances: {
        CurrencyType.USD: 2450.0,
        CurrencyType.EUR: 120.0,
        CurrencyType.GBP: 50.0,
        CurrencyType.KES: 15000.0,
      },
    );
  }

  void _fetchRates() {
    // Mock exchange rates (Base USD)
    state = state.copyWith(
      exchangeRates: {
        'EUR': 0.92,
        'GBP': 0.79,
        'JPY': 150.25,
        'KES': 130.50,
        'NGN': 1450.0,
        'ZAR': 18.90,
      },
    );
  }

  void convert(CurrencyType from, CurrencyType to, double amount) {
    if (amount <= 0 || (state.balances[from] ?? 0) < amount) return;

    final fromRate =
        from == CurrencyType.USD ? 1.0 : state.exchangeRates[from.name] ?? 1.0;
    final toRate =
        to == CurrencyType.USD ? 1.0 : state.exchangeRates[to.name] ?? 1.0;

    final usdAmount = amount / fromRate;
    final convertedAmount = usdAmount * toRate;

    final newBalances = Map<CurrencyType, double>.from(state.balances);
    newBalances[from] = (newBalances[from] ?? 0) - amount;
    newBalances[to] = (newBalances[to] ?? 0) + convertedAmount;

    state = state.copyWith(balances: newBalances);
  }
}

final multiCurrencyProvider =
    StateNotifierProvider<MultiCurrencyNotifier, MultiCurrencyState>((ref) {
  return MultiCurrencyNotifier();
});
