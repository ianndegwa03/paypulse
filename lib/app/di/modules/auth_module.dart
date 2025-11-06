import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get_it/get_it.dart';

/// The service locator instance.
final sl = GetIt.instance;

/// Registers the authentication module.
void registerAuthModule() {
  // Register FirebaseAuth
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);

  // Register GoogleSignIn
  sl.registerLazySingleton<GoogleSignIn>(() => GoogleSignIn());
}
