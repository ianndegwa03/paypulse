import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  Future<void> _handlePinLogin(String pin) async {
    HapticFeedback.mediumImpact();
    final notifier = ref.read(authNotifierProvider.notifier);
    await notifier.loginWithPin(pin);

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
          // Background Aesthetic
          _buildBackground(theme, isDark),

          SafeArea(
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: ((state.isBiometricEnabled || state.isPinEnabled) &&
                        !_showStandardLogin)
                    ? _buildFastLoginView(context, theme, state, isDark)
                    : _buildStandardLoginView(context, theme, state, isDark),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground(ThemeData theme, bool isDark) {
    return Stack(
      children: [
        Positioned(
          top: -100,
          right: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.primary.withOpacity(isDark ? 0.1 : 0.05),
            ),
          ),
        ),
        Positioned(
          bottom: -50,
          left: -50,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:
                  theme.colorScheme.secondary.withOpacity(isDark ? 0.1 : 0.05),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFastLoginView(
      BuildContext context, ThemeData theme, AuthState state, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLogo(theme),
          const SizedBox(height: 32),
          Text(
            'Fast Login',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Authenticate to continue',
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 48),
          if (state.isBiometricEnabled)
            _socialButton(
              context,
              Icons.fingerprint_rounded,
              theme.colorScheme.primary,
              _handleBiometricLogin,
              label: 'Use Biometrics',
            ),
          if (state.isBiometricEnabled && state.isPinEnabled)
            const SizedBox(height: 24),
          if (state.isPinEnabled)
            _socialButton(
              context,
              Icons.dialpad_rounded,
              theme.colorScheme.secondary,
              () => _showPinDialog(context, theme),
              label: 'Use PIN',
            ),
          const SizedBox(height: 48),
          TextButton(
            onPressed: () => setState(() => _showStandardLogin = true),
            child: Text(
              'Switch to Email/Password',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStandardLoginView(
      BuildContext context, ThemeData theme, AuthState state, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildLogo(theme),
            const SizedBox(height: 32),
            Text(
              'Welcome Back',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: -1,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Securely access your global wallet',
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            _buildInputLabel(context, 'Email Address'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _emailController,
              validator: EmailValidator.validate,
              keyboardType: TextInputType.emailAddress,
              decoration: _inputDecoration(
                  context, 'name@example.com', Icons.alternate_email_rounded),
            ),
            const SizedBox(height: 24),
            _buildInputLabel(context, 'Password'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _passwordController,
              validator: PasswordValidator.validate,
              obscureText: !_isPasswordVisible,
              decoration: _inputDecoration(
                context,
                '••••••••',
                Icons.lock_outline_rounded,
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    size: 20,
                    color: Colors.grey,
                  ),
                  onPressed: () =>
                      setState(() => _isPasswordVisible = !_isPasswordVisible),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => context.push('/forgot-password'),
                child: Text(
                  'Forgot Password?',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Login',
              isLoading: state.isLoading,
              onPressed: _handleLogin,
            ),
            if (state.hasError) ...[
              const SizedBox(height: 16),
              Text(
                state.errorMessage!,
                style: TextStyle(color: theme.colorScheme.error, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 40),
            _buildSocialDivider(theme),
            const SizedBox(height: 24),
            _buildSocialButtons(context, theme, state, isDark),
            const SizedBox(height: 40),
            _buildSignUpLink(context, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo(ThemeData theme) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.wallet_rounded,
          size: 48,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildSocialDivider(ThemeData theme) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('OR CONTINUE WITH',
              style: theme.textTheme.labelSmall
                  ?.copyWith(color: Colors.grey, letterSpacing: 1)),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }

  Widget _buildSocialButtons(
      BuildContext context, ThemeData theme, AuthState state, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _socialButton(context, Icons.g_mobiledata_rounded, Colors.red, () {}),
        const SizedBox(width: 20),
        _socialButton(context, Icons.apple_rounded,
            isDark ? Colors.white : Colors.black, () {}),
      ],
    );
  }

  Widget _buildSignUpLink(BuildContext context, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don't have an account?"),
        TextButton(
          onPressed: () => context.push('/register'),
          child: Text('Sign Up',
              style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  void _showPinDialog(BuildContext context, ThemeData theme) {
    final pinController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter PIN'),
        content: TextField(
          controller: pinController,
          keyboardType: TextInputType.number,
          obscureText: true,
          maxLength: 4,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24, letterSpacing: 16),
          decoration: const InputDecoration(
            hintText: '••••',
            counterText: '',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final pin = pinController.text;
              if (pin.length == 4) {
                Navigator.pop(context);
                _handlePinLogin(pin);
              }
            },
            child: const Text('Unlock'),
          ),
        ],
      ),
    );
  }

  Widget _buildInputLabel(BuildContext context, String label) {
    return Text(
      label,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade600,
          ),
    );
  }

  InputDecoration _inputDecoration(
      BuildContext context, String hint, IconData icon,
      {Widget? suffixIcon}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon,
          size: 20, color: theme.colorScheme.primary.withOpacity(0.5)),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: isDark
          ? Colors.white.withOpacity(0.05)
          : Colors.grey.withOpacity(0.05),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
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
    );
  }

  Widget _socialButton(
      BuildContext context, IconData icon, Color color, VoidCallback onTap,
      {String? label}) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 70,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border:
                  Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
            ),
            child: Icon(icon, size: 32, color: color),
          ),
        ),
        if (label != null) ...[
          const SizedBox(height: 8),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey),
          ),
        ],
      ],
    );
  }
}
