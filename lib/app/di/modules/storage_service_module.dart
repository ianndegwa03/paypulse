import 'package:get_it/get_it.dart';
import 'package:paypulse/data/local/storage_service.dart';

/// The service locator instance.
final sl = GetIt.instance;

/// Registers the storage service module.
///
/// This function is responsible for setting up and registering the `StorageService`
/// so that it can be injected into other parts of the application.
void registerStorageServiceModule() {
  sl.registerLazySingleton<StorageService>(() => StorageService());
}
