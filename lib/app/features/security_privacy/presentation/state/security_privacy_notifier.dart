import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecurityPrivacyState {
  final bool isBalanceHidden;
  final bool isAppBlurEnabled;
  final bool isBiometricRequired;
  final bool isIncognitoMode;
  final int autoLockMinutes; // 0 means disabled
  final DateTime? lastActiveTime;
  final bool isLocked;

  const SecurityPrivacyState({
    this.isBalanceHidden = false,
    this.isAppBlurEnabled = true,
    this.isBiometricRequired = false,
    this.isIncognitoMode = false,
    this.autoLockMinutes = 5,
    this.lastActiveTime,
    this.isLocked = false,
  });

  SecurityPrivacyState copyWith({
    bool? isBalanceHidden,
    bool? isAppBlurEnabled,
    bool? isBiometricRequired,
    bool? isIncognitoMode,
    int? autoLockMinutes,
    DateTime? lastActiveTime,
    bool? isLocked,
  }) {
    return SecurityPrivacyState(
      isBalanceHidden: isBalanceHidden ?? this.isBalanceHidden,
      isAppBlurEnabled: isAppBlurEnabled ?? this.isAppBlurEnabled,
      isBiometricRequired: isBiometricRequired ?? this.isBiometricRequired,
      isIncognitoMode: isIncognitoMode ?? this.isIncognitoMode,
      autoLockMinutes: autoLockMinutes ?? this.autoLockMinutes,
      lastActiveTime: lastActiveTime ?? this.lastActiveTime,
      isLocked: isLocked ?? this.isLocked,
    );
  }
}

class SecurityPrivacyNotifier extends StateNotifier<SecurityPrivacyState> {
  SecurityPrivacyNotifier() : super(const SecurityPrivacyState()) {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    state = state.copyWith(
      isBalanceHidden: prefs.getBool('sec_priv_balance_hidden') ?? false,
      isAppBlurEnabled: prefs.getBool('sec_priv_app_blur') ?? true,
      isBiometricRequired:
          prefs.getBool('sec_priv_biometric_required') ?? false,
      autoLockMinutes: prefs.getInt('sec_priv_auto_lock_min') ?? 5,
    );
  }

  void updateLastActive() {
    state = state.copyWith(lastActiveTime: DateTime.now(), isLocked: false);
  }

  void checkLockStatus() {
    if (state.autoLockMinutes == 0 || state.lastActiveTime == null) return;

    final now = DateTime.now();
    final difference = now.difference(state.lastActiveTime!);
    if (difference.inMinutes >= state.autoLockMinutes) {
      state = state.copyWith(isLocked: true);
    }
  }

  void unlock() {
    state = state.copyWith(isLocked: false, lastActiveTime: DateTime.now());
  }

  Future<void> toggleBalanceVisibility() async {
    state = state.copyWith(isBalanceHidden: !state.isBalanceHidden);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sec_priv_balance_hidden', state.isBalanceHidden);
  }

  Future<void> toggleAppBlur() async {
    state = state.copyWith(isAppBlurEnabled: !state.isAppBlurEnabled);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sec_priv_app_blur', state.isAppBlurEnabled);
  }

  Future<void> setAutoLock(int minutes) async {
    state = state.copyWith(autoLockMinutes: minutes);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('sec_priv_auto_lock_min', minutes);
  }

  void toggleIncognito() {
    state = state.copyWith(isIncognitoMode: !state.isIncognitoMode);
  }

  void setBiometricRequired(bool enable) async {
    state = state.copyWith(isBiometricRequired: enable);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sec_priv_biometric_required', enable);
  }
}

final securityPrivacyProvider =
    StateNotifierProvider<SecurityPrivacyNotifier, SecurityPrivacyState>((ref) {
  return SecurityPrivacyNotifier();
});
