import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

/// The service locator instance.
final sl = GetIt.instance;

/// Registers the storage module.
///
/// This function is responsible for setting up and registering `Hive` and
/// `SharedPreferences` for local data storage. It initializes Hive and
/// opens the necessary boxes.
Future<void> registerStorageModule() async {
  // Initialize Hive
  final appDocumentDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDir.path);
  sl.registerLazySingleton<HiveInterface>(() => Hive);

  // Register SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
}
