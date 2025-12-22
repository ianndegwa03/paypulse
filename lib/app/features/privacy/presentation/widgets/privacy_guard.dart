import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paypulse/app/features/privacy/presentation/state/privacy_provider.dart';

class PrivacyGuard extends ConsumerStatefulWidget {
  final Widget child;
  const PrivacyGuard({super.key, required this.child});

  @override
  ConsumerState<PrivacyGuard> createState() => _PrivacyGuardState();
}

class _PrivacyGuardState extends ConsumerState<PrivacyGuard>
    with WidgetsBindingObserver {
  bool _shouldBlur = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Blur when app is inactive or paused (background)
    final isBlurEnabled = ref.read(privacyProvider).isAppBlurEnabled;

    if (!isBlurEnabled) return;

    setState(() {
      _shouldBlur = state != AppLifecycleState.resumed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_shouldBlur)
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child:
                      Icon(Icons.lock_outline, color: Colors.white, size: 64),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
