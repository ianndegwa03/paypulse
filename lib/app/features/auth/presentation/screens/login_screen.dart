import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:paypulse/app/features/auth/presentation/state/auth_notifier.dart';
import 'package:paypulse/core/utils/validators/email_validator.dart';
import 'package:paypulse/core/utils/validators/password_validator.dart';
import 'package:paypulse/core/widgets/buttons/primary_button.dart';
import 'package:paypulse/core/widgets/inputs/text_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      final notifier = ref.read(authNotifierProvider.notifier);
      // Dismiss keyboard
      FocusScope.of(context).unfocus();

      await notifier.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      // Check state after login attempt
      if (!mounted) return;
      final state = ref.read(authNotifierProvider);
      if (state.isAuthenticated) {
        context.go('/dashboard');
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    final notifier = ref.read(authNotifierProvider.notifier);
    await notifier.signInWithGoogle();

    if (!mounted) return;
    final state = ref.read(authNotifierProvider);
    if (state.isAuthenticated) {
      context.go('/dashboard');
    } else if (state.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.errorMessage!),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _handleAppleSignIn() async {
    final notifier = ref.read(authNotifierProvider.notifier);
    await notifier.signInWithApple();

    if (!mounted) return;
    final state = ref.read(authNotifierProvider);
    if (state.isAuthenticated) {
      context.go('/dashboard');
    } else if (state.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.errorMessage!),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _handleRegister() {
    context.push('/register');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(authNotifierProvider);

    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => FocusScope.of(context).unfocus(),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.payments_rounded,
                      size: 64,
                      color: theme.primaryColor,
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Welcome Back',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign in to continue to PayPulse',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.textTheme.bodySmall?.color,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),

                    // Email Field
                    AppTextField(
                      controller: _emailController,
                      label: 'Email Address',
                      hintText: 'Enter your email',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email_outlined,
                      validator: EmailValidator.validate,
                    ),
                    const SizedBox(height: 16),

                    // Password Field
                    AppTextField(
                      controller: _passwordController,
                      label: 'Password',
                      hintText: 'Enter your password',
                      obscureText: !_isPasswordVisible,
                      prefixIcon: Icons.lock_outline,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                      validator: PasswordValidator.validate,
                    ),

                    const SizedBox(height: 16),

                    // Remember Me & Forgot Password
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: _rememberMe,
                              onChanged: (value) {
                                setState(() {
                                  _rememberMe = value ?? false;
                                });
                              },
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            Text('Remember me',
                                style: theme.textTheme.bodyMedium),
                          ],
                        ),
                        TextButton(
                          onPressed: () {
                            context.push('/forgot-password');
                          },
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: theme.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Login Button
                    PrimaryButton(
                      label: 'Sign In',
                      isLoading: state.isLoading,
                      onPressed: _handleLogin,
                    ),

                    const SizedBox(height: 24),

                    // Error Message
                    if (state.hasError)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          state.errorMessage!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    if (state.hasError) const SizedBox(height: 24),

                    // Social Login Divider
                    Row(
                      children: [
                        Expanded(child: Divider(color: theme.dividerColor)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Or continue with',
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                        Expanded(child: Divider(color: theme.dividerColor)),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Social Login Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: _handleGoogleSignIn,
                          icon: Image.asset(
                            'assets/icons/google.png',
                            height: 24,
                            width: 24,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.g_mobiledata, size: 24),
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: theme.colorScheme.surface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side:
                                  BorderSide(color: theme.colorScheme.outline),
                            ),
                            padding: const EdgeInsets.all(12),
                          ),
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          onPressed: _handleAppleSignIn,
                          icon: Image.asset(
                            'assets/icons/apple.png',
                            height: 24,
                            width: 24,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.apple, size: 24),
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: theme.colorScheme.surface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side:
                                  BorderSide(color: theme.colorScheme.outline),
                            ),
                            padding: const EdgeInsets.all(12),
                          ),
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Facebook sign-in not implemented')),
                            );
                          },
                          icon: Image.asset(
                            'assets/icons/facebook.png',
                            height: 24,
                            width: 24,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.facebook, size: 24),
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: theme.colorScheme.surface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side:
                                  BorderSide(color: theme.colorScheme.outline),
                            ),
                            padding: const EdgeInsets.all(12),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Register Link
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                            ),
                          ),
                          TextButton(
                            onPressed: _handleRegister,
                            child: Text(
                              'Sign Up',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
