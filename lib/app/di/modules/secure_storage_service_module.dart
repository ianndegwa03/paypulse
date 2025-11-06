import 'package:get_it/get_it.dart';
import 'package:paypulse/data/local/secure_storage_service.dart';

/// The service locator instance.
final sl = GetIt.instance;

/// Registers the secure storage service module.
///
/// This function is responsible for setting up and registering the `SecureStorageService`
/// so that it can be injected into other parts of the application.
void registerSecureStorageServiceModule() {
  sl.registerLazySingleton<SecureStorageService>(() => SecureStorageService());
}
