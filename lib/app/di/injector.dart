// lib/app/di/injector.dart
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'injector.config.dart';

final GetIt getIt = GetIt.instance;

@InjectableInit(
  initializerName: r'$initGetIt',
  preferRelativeImports: true,
  asExtension: false,
  generateForDir: ['lib/app/di/modules'],
)
void configureDependencies() => $initGetIt(getIt);