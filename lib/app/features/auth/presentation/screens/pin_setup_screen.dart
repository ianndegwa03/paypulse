import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:paypulse/app/features/auth/presentation/state/auth_notifier.dart';

class PinSetupScreen extends ConsumerStatefulWidget {
  const PinSetupScreen({super.key});

  @override
  ConsumerState<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends ConsumerState<PinSetupScreen> {
  final _pinController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String? _firstPin;
  bool _isConfirming = false;

  @override
  void dispose() {
    _pinController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onCompleted(String pin) async {
    _pinController.clear();

    // Slight delay to show the last dot filled
    await Future.delayed(const Duration(milliseconds: 100));

    if (!_isConfirming) {
      if (mounted) {
        setState(() {
          _firstPin = pin;
          _isConfirming = true;
        });
      }
    } else {
      if (pin == _firstPin) {
        // PIN Match
        await ref.read(authNotifierProvider.notifier).enablePin(true, pin);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("PIN Security Enabled")),
          );
          context.pop();
        }
      } else {
        // PIN Mismatch
        if (mounted) {
          setState(() {
            _firstPin = null;
            _isConfirming = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("PINs do not match. Start over.")),
          );
        }
      }
    }
    // Refocus for next input
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
        title: const Text("Set Security PIN"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _isConfirming
                    ? Icons.lock_outline_rounded
                    : Icons.lock_open_rounded,
                size: 64,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 32),
              Text(
                _isConfirming ? "Confirm your PIN" : "Create a 4-digit PIN",
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _isConfirming
                    ? "Re-enter to verify"
                    : "Enhance your account security with a PIN code.",
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
                              color: hasValue
                                  ? theme.colorScheme.primary
                                  : theme.dividerColor,
                              width: hasValue ? 2 : 1),
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

              // Invisible TextField to capture focus and input
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
                    setState(() {});
                    if (val.length == 4) {
                      _onCompleted(val);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
