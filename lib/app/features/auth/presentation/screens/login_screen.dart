import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:paypulse/app/features/auth/presentation/state/auth_notifier.dart';
import 'package:paypulse/app/features/auth/presentation/state/auth_state.dart';
import 'package:paypulse/core/utils/validators/email_validator.dart';
import 'package:paypulse/core/utils/validators/password_validator.dart';
import 'package:paypulse/core/widgets/buttons/primary_button.dart';

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
  bool _showStandardLogin = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(authNotifierProvider);
      if (state.isBiometricEnabled && !_showStandardLogin) {
        _handleBiometricLogin();
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      HapticFeedback.mediumImpact();
      final notifier = ref.read(authNotifierProvider.notifier);
      FocusScope.of(context).unfocus();

      await notifier.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;
      final state = ref.read(authNotifierProvider);
      if (state.isAuthenticated) {
        context.go('/dashboard');
      }
    }
  }

  Future<void> _handleBiometricLogin() async {
    HapticFeedback.heavyImpact();
    final notifier = ref.read(authNotifierProvider.notifier);
    await notifier.loginWithBiometrics();

    if (!mounted) return;
    final state = ref.read(authNotifierProvider);
    if (state.isAuthenticated) {
      context.go('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(authNotifierProvider);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(theme, isDark),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: AnimatedSwitcher(
                  duration: 400.ms,
                  child: ((state.isBiometricEnabled || state.isPinEnabled) &&
                          !_showStandardLogin)
                      ? _buildFastLoginView(context, theme, state)
                      : _buildStandardLoginView(context, theme, state),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground(ThemeData theme, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [theme.scaffoldBackgroundColor, theme.colorScheme.surface]
              : [Colors.white, theme.colorScheme.primary.withOpacity(0.05)],
        ),
      ),
    );
  }

  Widget _buildFastLoginView(
      BuildContext context, ThemeData theme, AuthState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeroIcon(
              theme, Icons.security_rounded, theme.colorScheme.primary),
          const SizedBox(height: 32),
          Text(
            'Secure Access',
            style: theme.textTheme.headlineMedium
                ?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -1),
          ).animate().fadeIn().moveY(begin: 10, end: 0),
          const SizedBox(height: 8),
          Text(
            'Authenticate to unlock your wallet',
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: Colors.grey.shade600),
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 64),
          if (state.isBiometricEnabled) ...[
            _buildLoginMethod(
              context,
              icon: Icons.fingerprint_rounded,
              label: 'Biometric Unlock',
              onTap: _handleBiometricLogin,
              color: theme.colorScheme.primary,
            ).animate().scale(delay: 200.ms, curve: Curves.easeOutBack),
            const SizedBox(height: 32),
          ],
          if (state.isPinEnabled)
            _buildLoginMethod(
              context,
              icon: Icons.lock_rounded,
              label: 'Login with PIN',
              onTap: () => context.push('/pin-login'),
              color: theme.colorScheme.secondary,
            ).animate().scale(delay: 300.ms, curve: Curves.easeOutBack),
          const SizedBox(height: 48),
          TextButton(
            onPressed: () => setState(() => _showStandardLogin = true),
            child: Text(
              'Switch to Email & Password',
              style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold),
            ),
          ).animate().fadeIn(delay: 400.ms),
        ],
      ),
    );
  }

  Widget _buildStandardLoginView(
      BuildContext context, ThemeData theme, AuthState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(40),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeroIcon(
                theme, Icons.wallet_rounded, theme.colorScheme.primary),
            const SizedBox(height: 32),
            Text(
              'Welcome Back',
              style: theme.textTheme.headlineMedium
                  ?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -1),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            _buildFieldLabel(theme, 'EMAIL ADDRESS'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _emailController,
              validator: EmailValidator.validate,
              keyboardType: TextInputType.emailAddress,
              decoration: _inputStyle(
                  theme, 'name@example.com', Icons.alternate_email_rounded),
            ),
            const SizedBox(height: 24),
            _buildFieldLabel(theme, 'PASSWORD'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _passwordController,
              validator: PasswordValidator.validate,
              obscureText: !_isPasswordVisible,
              decoration: _inputStyle(
                theme,
                '••••••••',
                Icons.lock_outline_rounded,
                suffix: IconButton(
                  icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.grey,
                      size: 20),
                  onPressed: () =>
                      setState(() => _isPasswordVisible = !_isPasswordVisible),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => context.push('/forgot-password'),
                child: Text('Forgot Password?',
                    style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              label: 'Sign In',
              isLoading: state.isLoading,
              onPressed: _handleLogin,
            ),
            if (state.hasError) ...[
              const SizedBox(height: 16),
              Text(
                state.errorMessage!,
                style: TextStyle(color: theme.colorScheme.error, fontSize: 13),
                textAlign: TextAlign.center,
              ).animate().shake(),
            ],
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("New to PayPulse?",
                    style: TextStyle(color: Colors.grey.shade600)),
                TextButton(
                  onPressed: () => context.push('/register'),
                  child: Text('Create Account',
                      style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ).animate().fadeIn(duration: 400.ms).moveY(begin: 20, end: 0),
      ),
    );
  }

  Widget _buildHeroIcon(ThemeData theme, IconData icon, Color color) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 48, color: color),
      ),
    ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack);
  }

  Widget _buildFieldLabel(ThemeData theme, String label) {
    return Text(
      label,
      style: theme.textTheme.labelSmall?.copyWith(
        color: Colors.grey.shade600,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.2,
      ),
    );
  }

  InputDecoration _inputStyle(ThemeData theme, String hint, IconData icon,
      {Widget? suffix}) {
    final isDark = theme.brightness == Brightness.dark;
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon,
          size: 20, color: theme.colorScheme.primary.withOpacity(0.5)),
      suffixIcon: suffix,
      filled: true,
      fillColor:
          isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withAlpha(10),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide:
            BorderSide(color: theme.colorScheme.outline.withOpacity(0.05)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide:
            BorderSide(color: theme.colorScheme.primary.withOpacity(0.5)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    );
  }

  Widget _buildLoginMethod(BuildContext context,
      {required IconData icon,
      required String label,
      required VoidCallback onTap,
      required Color color}) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: Icon(icon, size: 40, color: color),
          ),
          const SizedBox(height: 12),
          Text(label,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}
