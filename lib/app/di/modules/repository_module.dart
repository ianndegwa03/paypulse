import 'package:get_it/get_it.dart';
import 'package:paypulse/data/repositories/auth_repository_impl.dart';
import 'package:paypulse/domain/repositories/auth_repository.dart';

/// The service locator instance.
final sl = GetIt.instance;

/// Registers the repository module.
///
/// This function is responsible for setting up and registering the repositories
/// so that they can be injected into other parts of the application.
void registerRepositoryModule() {
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl());
}
