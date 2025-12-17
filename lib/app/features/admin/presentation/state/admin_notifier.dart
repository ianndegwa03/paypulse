import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paypulse/app/di/injector.dart';
import 'package:paypulse/domain/entities/admin_settings_entity.dart';
import 'package:paypulse/domain/use_cases/admin/get_admin_settings_use_case.dart';
import 'package:paypulse/domain/use_cases/admin/update_admin_settings_use_case.dart';

class AdminState {
  final bool isLoading;
  final AdminSettingsEntity? settings;
  final String? error;

  const AdminState({
    this.isLoading = false,
    this.settings,
    this.error,
  });

  AdminState copyWith({
    bool? isLoading,
    AdminSettingsEntity? settings,
    String? error,
  }) {
    return AdminState(
      isLoading: isLoading ?? this.isLoading,
      settings: settings ?? this.settings,
      error: error,
    );
  }
}

class AdminNotifier extends StateNotifier<AdminState> {
  final GetAdminSettingsUseCase _getSettings;
  final UpdateAdminSettingsUseCase _updateSettings;

  AdminNotifier(this._getSettings, this._updateSettings)
      : super(const AdminState()) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _getSettings();
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (settings) => state = state.copyWith(
        isLoading: false,
        settings: settings,
      ),
    );
  }

  Future<void> toggleFeature(String feature) async {
    if (state.settings == null) return;

    final current = state.settings!;
    late AdminSettingsEntity updated;

    switch (feature) {
      case 'investment':
        updated =
            current.copyWith(isInvestmentEnabled: !current.isInvestmentEnabled);
        break;
      case 'crypto':
        updated = current.copyWith(isCryptoEnabled: !current.isCryptoEnabled);
        break;
      case 'savings':
        updated = current.copyWith(isSavingsEnabled: !current.isSavingsEnabled);
        break;
      case 'bills':
        updated = current.copyWith(isBillsEnabled: !current.isBillsEnabled);
        break;
      case 'social':
        updated = current.copyWith(isSocialEnabled: !current.isSocialEnabled);
        break;
      case 'maintenance':
        updated =
            current.copyWith(isMaintenanceMode: !current.isMaintenanceMode);
        break;
      default:
        return;
    }

    final result = await _updateSettings(updated);
    result.fold(
      (failure) => state = state.copyWith(error: failure.message),
      (_) => state = state.copyWith(settings: updated),
    );
  }
}

final adminProvider = StateNotifierProvider<AdminNotifier, AdminState>((ref) {
  return AdminNotifier(
    Injector.get<GetAdminSettingsUseCase>(),
    Injector.get<UpdateAdminSettingsUseCase>(),
  );
});
