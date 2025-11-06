import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';

/// The service locator instance.
final sl = GetIt.instance;

/// Registers the firestore module.
///
/// This function is responsible for setting up and registering the `FirebaseFirestore`
/// instance so that it can be injected into other parts of the application.
void registerFirestoreModule() {
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
}
