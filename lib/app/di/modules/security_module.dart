// lib/app/di/modules/security_module.dart
import 'package:injectable/injectable.dart';
import 'package:paypulse/features/security/data/repositories/security_repository_impl.dart';
import 'package:paypulse/features/security/domain/repositories/security_repository.dart';
import 'package:paypulse/core/services/biometric/biometric_service.dart';
import 'package:paypulse/core/services/location/location_service.dart';

@module
abstract class SecurityModule {
  
  @singleton
  BiometricService get biometricService => BiometricService();
  
  @singleton
  LocationService get locationService => LocationService();
  
  @singleton
  SecurityRepository get securityRepository => SecurityRepositoryImpl(
    biometricService: biometricService,
    locationService: locationService,
  );
}