import 'package:paypulse/domain/entities/enums.dart';
import 'package:paypulse/domain/entities/admin_settings_entity.dart';

class FeatureFlagService {
  AdminSettingsEntity _settings = const AdminSettingsEntity();

  void updateSettings(AdminSettingsEntity settings) {
    _settings = settings;
  }

  bool isFeatureEnabled(String featureName, {UserRole? userRole}) {
    // Admins bypass feature flags (unless maintenance mode?)
    if (userRole == UserRole.admin) return true;

    // Global maintenance mode check
    if (_settings.isMaintenanceMode) return false;

    switch (featureName) {
      case 'investment':
        return _settings.isInvestmentEnabled;
      case 'crypto':
        return _settings.isCryptoEnabled;
      case 'savings':
        return _settings.isSavingsEnabled;
      case 'bills':
        return _settings.isBillsEnabled;
      case 'social':
        return _settings.isSocialEnabled;
      default:
        return true;
    }
  }
}
