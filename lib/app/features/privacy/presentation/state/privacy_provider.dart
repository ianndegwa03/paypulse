import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrivacyState {
  final bool isBalanceHidden;
  final bool isAppBlurEnabled;
  final bool isBiometricRequired;
  final bool isIncognitoMode;

  const PrivacyState({
    this.isBalanceHidden = false,
    this.isAppBlurEnabled = true,
    this.isBiometricRequired = false,
    this.isIncognitoMode = false,
  });

  PrivacyState copyWith({
    bool? isBalanceHidden,
    bool? isAppBlurEnabled,
    bool? isBiometricRequired,
    bool? isIncognitoMode,
  }) {
    return PrivacyState(
      isBalanceHidden: isBalanceHidden ?? this.isBalanceHidden,
      isAppBlurEnabled: isAppBlurEnabled ?? this.isAppBlurEnabled,
      isBiometricRequired: isBiometricRequired ?? this.isBiometricRequired,
      isIncognitoMode: isIncognitoMode ?? this.isIncognitoMode,
    );
  }
}

class PrivacyNotifier extends StateNotifier<PrivacyState> {
  PrivacyNotifier() : super(const PrivacyState()) {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    state = state.copyWith(
      isBalanceHidden: prefs.getBool('privacy_balance_hidden') ?? false,
      isAppBlurEnabled: prefs.getBool('privacy_app_blur') ?? true,
      isBiometricRequired: prefs.getBool('privacy_biometric_required') ?? false,
    );
  }

  Future<void> toggleBalanceVisibility() async {
    state = state.copyWith(isBalanceHidden: !state.isBalanceHidden);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('privacy_balance_hidden', state.isBalanceHidden);
  }

  Future<void> toggleAppBlur() async {
    state = state.copyWith(isAppBlurEnabled: !state.isAppBlurEnabled);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('privacy_app_blur', state.isAppBlurEnabled);
  }

  void toggleIncognito() {
    state = state.copyWith(isIncognitoMode: !state.isIncognitoMode);
  }

  void requireBiometric(bool enable) async {
    state = state.copyWith(isBiometricRequired: enable);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('privacy_biometric_required', enable);
  }
}

final privacyProvider =
    StateNotifierProvider<PrivacyNotifier, PrivacyState>((ref) {
  return PrivacyNotifier();
});
