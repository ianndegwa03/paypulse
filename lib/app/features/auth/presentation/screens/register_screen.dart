import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:paypulse/app/features/auth/presentation/state/auth_notifier.dart';
import 'package:paypulse/core/utils/validators/email_validator.dart';
import 'package:paypulse/core/utils/validators/password_validator.dart';
import 'package:paypulse/core/widgets/buttons/primary_button.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      HapticFeedback.mediumImpact();
      final notifier = ref.read(authNotifierProvider.notifier);
      await notifier.register(
        _emailController.text.trim(),
        _passwordController.text,
        _usernameController.text.trim(),
        _firstNameController.text.trim(),
        _lastNameController.text.trim(),
      );

      if (!mounted) return;
      final state = ref.read(authNotifierProvider);
      if (state.isAuthenticated) {
        context.go('/dashboard');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(authNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Account Setup',
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Join the global wallet 🌍',
                  style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900, letterSpacing: -0.5),
                  textAlign: TextAlign.center,
                ).animate().fadeIn().moveY(begin: 10, end: 0),
                const SizedBox(height: 48),
                Row(
                  children: [
                    Expanded(
                      child: _buildField(
                        theme,
                        'FIRST NAME',
                        _firstNameController,
                        'John',
                        Icons.person_outline,
                        validator: (v) =>
                            (v?.isEmpty ?? true) ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildField(
                        theme,
                        'LAST NAME',
                        _lastNameController,
                        'Doe',
                        Icons.person_outline,
                        validator: (v) =>
                            (v?.isEmpty ?? true) ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildField(
                  theme,
                  'USERNAME',
                  _usernameController,
                  'johndoe',
                  Icons.alternate_email_rounded,
                  validator: (v) => (v?.isEmpty ?? true) ? 'Required' : null,
                ),
                const SizedBox(height: 24),
                _buildField(
                  theme,
                  'EMAIL',
                  _emailController,
                  'john@example.com',
                  Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: EmailValidator.validate,
                ),
                const SizedBox(height: 24),
                _buildField(
                  theme,
                  'PASSWORD',
                  _passwordController,
                  '••••••••',
                  Icons.lock_outline,
                  obscureText: true,
                  validator: PasswordValidator.validate,
                ),
                const SizedBox(height: 24),
                _buildField(
                  theme,
                  'CONFIRM PASSWORD',
                  _confirmPasswordController,
                  '••••••••',
                  Icons.lock_reset,
                  obscureText: true,
                  validator: (v) => v != _passwordController.text
                      ? 'Passwords do not match'
                      : null,
                ),
                const SizedBox(height: 48),
                PrimaryButton(
                  onPressed: _handleRegister,
                  label: 'Complete Onboarding',
                  isLoading: state.isLoading,
                ),
                if (state.hasError) ...[
                  const SizedBox(height: 16),
                  Text(
                    state.errorMessage!,
                    style:
                        TextStyle(color: theme.colorScheme.error, fontSize: 13),
                    textAlign: TextAlign.center,
                  ).animate().shake(),
                ],
                const SizedBox(height: 40),
                Center(
                  child: TextButton(
                    onPressed: () => context.go('/login'),
                    child: RichText(
                      text: TextSpan(
                        text: "Already have an account? ",
                        style: theme.textTheme.bodyMedium,
                        children: [
                          TextSpan(
                            text: "Sign In",
                            style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    ThemeData theme,
    String label,
    TextEditingController controller,
    String hint,
    IconData icon, {
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    final isDark = theme.brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon,
                size: 20,
                color: theme.colorScheme.primary.withValues(alpha: 0.5)),
            filled: true,
            fillColor: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.grey.withAlpha(10),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                  color: theme.colorScheme.outline.withValues(alpha: 0.05)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                  color: theme.colorScheme.primary.withValues(alpha: 0.5)),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          ),
        ),
      ],
    );
  }
}
