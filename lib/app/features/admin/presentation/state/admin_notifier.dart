import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paypulse/app/di/injector.dart';
import 'package:paypulse/core/base/base_state.dart';
import 'package:paypulse/core/logging/logger_service.dart';
import 'package:paypulse/domain/entities/admin_settings_entity.dart';
import 'package:paypulse/domain/use_cases/admin/get_admin_settings_use_case.dart';
import 'package:paypulse/domain/use_cases/admin/update_admin_settings_use_case.dart';

class AdminState extends BaseState {
  final AdminSettingsEntity? settings;

  const AdminState({
    super.isLoading = false,
    this.settings,
    super.errorMessage,
    super.successMessage,
  });

  @override
  AdminState copyWith({
    bool? isLoading,
    AdminSettingsEntity? settings,
    String? errorMessage,
    String? successMessage,
  }) {
    return AdminState(
      isLoading: isLoading ?? this.isLoading,
      settings: settings ?? this.settings,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [settings, ...super.props];
}

class AdminNotifier extends StateNotifier<AdminState> {
  final GetAdminSettingsUseCase _getSettings;
  final UpdateAdminSettingsUseCase _updateSettings;
  final _logger = LoggerService.instance;

  AdminNotifier(this._getSettings, this._updateSettings)
      : super(const AdminState()) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final result = await _getSettings();
      result.fold(
        (failure) {
          _logger.e('Failed to load admin settings: ${failure.message}',
              tag: 'AdminNotifier');
          state = state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
          );
        },
        (settings) {
          _logger.d('Admin settings loaded successfully', tag: 'AdminNotifier');
          state = state.copyWith(
            isLoading: false,
            settings: settings,
          );
        },
      );
    } catch (e) {
      _logger.e('Unexpected error loading settings: $e', tag: 'AdminNotifier');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'An unexpected error occurred while loading settings',
      );
    }
  }

  Future<void> toggleFeature(String feature) async {
    if (state.settings == null) {
      _logger.w('Attempted to toggle feature without settings loaded',
          tag: 'AdminNotifier');
      return;
    }

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
        _logger.w('Unknown feature toggle requested: $feature',
            tag: 'AdminNotifier');
        return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await _updateSettings(updated);
      result.fold(
        (failure) {
          _logger.e('Failed to update feature $feature: ${failure.message}',
              tag: 'AdminNotifier');
          state = state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
          );
        },
        (_) {
          _logger.d('Feature $feature toggled successfully',
              tag: 'AdminNotifier');
          state = state.copyWith(
            isLoading: false,
            settings: updated,
            successMessage: 'Settings updated successfully',
          );
        },
      );
    } catch (e) {
      _logger.e('Unexpected error toggling feature: $e', tag: 'AdminNotifier');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'An unexpected error occurred while updating settings',
      );
    }
  }
}

final adminProvider = StateNotifierProvider<AdminNotifier, AdminState>((ref) {
  return AdminNotifier(
    getIt<GetAdminSettingsUseCase>(),
    getIt<UpdateAdminSettingsUseCase>(),
  );
});
