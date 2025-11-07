import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paypulse/domain/repositories/auth_repository.dart';
import 'package:paypulse/app/features/auth/presentation/state/auth_state.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(AuthInitial()) {
    _authRepository.user.listen((user) {
      if (user != null) {
        state = Authenticated(user);
      } else {
        state = Unauthenticated();
      }
    });
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    state = AuthLoading();
    try {
      await _authRepository.signInWithEmailAndPassword(email, password);
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  Future<void> signUpWithEmailAndPassword(String email, String password) async {
    state = AuthLoading();
    try {
      await _authRepository.signUpWithEmailAndPassword(email, password);
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  Future<void> signInWithGoogle() async {
    state = AuthLoading();
    try {
      await _authRepository.signInWithGoogle();
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  Future<void> signInWithApple() async {
    state = AuthLoading();
    try {
      await _authRepository.signInWithApple();
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
  }
}
