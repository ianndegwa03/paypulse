import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:paypulse/app/features/auth/presentation/state/auth_providers.dart';
import 'package:paypulse/app/features/auth/presentation/state/auth_state.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    ref.listen<AuthState>(authStateProvider, (previous, next) {
      if (next is AuthError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: Colors.redAccent,
          ),
        );
      } else if (next is Authenticated) {
        // Redirect when authenticated
        context.go('/dashboard');
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Text(
                  "Welcome back to PayPulse 💳",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Email is required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Password is required'
                      : null,
                ),
                const SizedBox(height: 24),

                // Login Button
                if (authState is AuthLoading)
                  const CircularProgressIndicator()
                else
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          ref
                              .read(authStateProvider.notifier)
                              .signInWithEmailAndPassword(
                                _emailController.text.trim(),
                                _passwordController.text.trim(),
                              );
                        }
                      },
                      child: const Text('Login'),
                    ),
                  ),
                const SizedBox(height: 12),

                //  Register Link
                TextButton(
                  onPressed: () => context.go('/register'),
                  child: const Text("Don't have an account? Register here"),
                ),
                const SizedBox(height: 16),

                //  Social logins
                if (authState is! AuthLoading)
                  Column(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          ref.read(authStateProvider.notifier).signInWithGoogle();
                        },
                        icon: const Icon(Icons.login),
                        label: const Text('Sign in with Google'),
                      ),
                      if (defaultTargetPlatform == TargetPlatform.iOS)
                        ElevatedButton.icon(
                          onPressed: () {
                            ref
                                .read(authStateProvider.notifier)
                                .signInWithApple();
                          },
                          icon: const Icon(Icons.apple),
                          label: const Text('Sign in with Apple'),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
