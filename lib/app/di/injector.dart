import 'package:get_it/get_it.dart';

/// Global GetIt instance for dependency injection
final GetIt getIt = GetIt.instance;

/// Convenience class for accessing dependencies
class Injector {
  static T get<T extends Object>() => getIt.get<T>();
}