import 'package:equatable/equatable.dart';

class AdminSettingsEntity extends Equatable {
  final bool isInvestmentEnabled;
  final bool isCryptoEnabled;
  final bool isSavingsEnabled;
  final bool isBillsEnabled;
  final bool isSocialEnabled;
  final bool isMaintenanceMode;
  final String? minimumAppVersion;

  const AdminSettingsEntity({
    this.isInvestmentEnabled = true,
    this.isCryptoEnabled = true,
    this.isSavingsEnabled = true,
    this.isBillsEnabled = true,
    this.isSocialEnabled = true,
    this.isMaintenanceMode = false,
    this.minimumAppVersion,
  });

  @override
  List<Object?> get props => [
        isInvestmentEnabled,
        isCryptoEnabled,
        isSavingsEnabled,
        isBillsEnabled,
        isSocialEnabled,
        isMaintenanceMode,
        minimumAppVersion,
      ];

  AdminSettingsEntity copyWith({
    bool? isInvestmentEnabled,
    bool? isCryptoEnabled,
    bool? isSavingsEnabled,
    bool? isBillsEnabled,
    bool? isSocialEnabled,
    bool? isMaintenanceMode,
    String? minimumAppVersion,
  }) {
    return AdminSettingsEntity(
      isInvestmentEnabled: isInvestmentEnabled ?? this.isInvestmentEnabled,
      isCryptoEnabled: isCryptoEnabled ?? this.isCryptoEnabled,
      isSavingsEnabled: isSavingsEnabled ?? this.isSavingsEnabled,
      isBillsEnabled: isBillsEnabled ?? this.isBillsEnabled,
      isSocialEnabled: isSocialEnabled ?? this.isSocialEnabled,
      isMaintenanceMode: isMaintenanceMode ?? this.isMaintenanceMode,
      minimumAppVersion: minimumAppVersion ?? this.minimumAppVersion,
    );
  }
}
