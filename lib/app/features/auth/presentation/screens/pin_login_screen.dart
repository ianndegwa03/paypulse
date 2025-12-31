import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:paypulse/app/features/auth/presentation/state/auth_notifier.dart';

class PinLoginScreen extends ConsumerStatefulWidget {
  const PinLoginScreen({super.key});

  @override
  ConsumerState<PinLoginScreen> createState() => _PinLoginScreenState();
}

class _PinLoginScreenState extends ConsumerState<PinLoginScreen> {
  final _pinController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _getError = false;

  @override
  void dispose() {
    _pinController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onCompleted(String pin) async {
    _pinController.clear();
    setState(() => _getError = false);

    try {
      await ref.read(authNotifierProvider.notifier).loginWithPin(pin);

      if (!mounted) return;
      final state = ref.read(authNotifierProvider);
      if (state.isAuthenticated) {
        context.go('/dashboard');
      } else {
        setState(() => _getError = true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.errorMessage ?? "Incorrect PIN")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _getError = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
    // Refocus
    if (mounted) FocusScope.of(context).requestFocus(_focusNode);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle),
                child: Icon(
                  Icons.lock_rounded,
                  size: 40,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                "Welcome Back",
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Enter your PIN to access PayPulse",
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 48),

              // Custom PIN Input
              GestureDetector(
                onTap: () => FocusScope.of(context).requestFocus(_focusNode),
                child: SizedBox(
                  height: 60,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (index) {
                      final hasValue = _pinController.text.length > index;
                      return Container(
                        width: 56,
                        height: 56,
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: _getError
                                  ? Colors.red
                                  : (hasValue
                                      ? theme.colorScheme.primary
                                      : theme.dividerColor),
                              width: hasValue || _getError ? 2 : 1),
                          borderRadius: BorderRadius.circular(16),
                          color: theme.cardColor,
                        ),
                        child: Center(
                          child: hasValue
                              ? const Icon(Icons.circle, size: 12)
                              : null,
                        ),
                      );
                    }),
                  ),
                ),
              ),

              // Invisible TextField
              Opacity(
                opacity: 0,
                child: TextField(
                  controller: _pinController,
                  focusNode: _focusNode,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  maxLength: 4,
                  onChanged: (val) {
                    setState(() => _getError = false);
                    if (val.length == 4) {
                      _onCompleted(val);
                    }
                  },
                ),
              ),

              const SizedBox(height: 32),
              TextButton(
                onPressed: () => context.go('/login'),
                child: const Text("Forgot PIN? Login with Password"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
