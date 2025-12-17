import 'package:paypulse/domain/entities/admin_settings_entity.dart';

abstract class AdminDataSource {
  Future<AdminSettingsEntity> getSettings();
  Future<void> updateSettings(AdminSettingsEntity settings);
}

class AdminDataSourceImpl implements AdminDataSource {
  // Simulating remote storage for now
  AdminSettingsEntity _currentSettings = const AdminSettingsEntity();

  @override
  Future<AdminSettingsEntity> getSettings() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _currentSettings;
  }

  @override
  Future<void> updateSettings(AdminSettingsEntity settings) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentSettings = settings;
    // Real implementation would save to Firestore 'admin_settings' collection
  }
}
