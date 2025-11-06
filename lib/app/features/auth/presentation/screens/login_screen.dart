import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paypulse/app/features/auth/presentation/state/auth_providers.dart';
import 'package:paypulse/app/features/auth/presentation/state/auth_state.dart';

class LoginScreen extends ConsumerWidget {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    ref.listen<AuthState>(authStateProvider, (previous, next) {
      if (next is AuthError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message)),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            if (authState is AuthLoading)
              const CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: () {
                  ref.read(authStateProvider.notifier).signInWithEmailAndPassword(
                        _emailController.text,
                        _passwordController.text,
                      );
                },
                child: const Text('Login'),
              ),
            const SizedBox(height: 16),
            if (authState is! AuthLoading)
              ElevatedButton(
                onPressed: () {
                  ref.read(authStateProvider.notifier).signInWithGoogle();
                },
                child: const Text('Sign in with Google'),
              ),
          ],
        ),
      ),
    );
  }
}
