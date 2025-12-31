import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paypulse/app/features/security_privacy/presentation/state/security_privacy_notifier.dart';

class PrivacyOverlayWrapper extends ConsumerStatefulWidget {
  final Widget child;

  const PrivacyOverlayWrapper({super.key, required this.child});

  @override
  ConsumerState<PrivacyOverlayWrapper> createState() =>
      _PrivacyOverlayWrapperState();
}

class _PrivacyOverlayWrapperState extends ConsumerState<PrivacyOverlayWrapper>
    with WidgetsBindingObserver {
  bool _isInBackground = false;

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
    setState(() {
      _isInBackground = state == AppLifecycleState.inactive ||
          state == AppLifecycleState.paused;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isBlurEnabled = ref.watch(securityPrivacyProvider).isAppBlurEnabled;
    final showOverlay = _isInBackground && isBlurEnabled;

    return Stack(
      children: [
        widget.child,
        if (showOverlay)
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.lock_outline,
                          size: 80, color: Colors.white),
                      const SizedBox(height: 16),
                      const Text(
                        "PAYPULSE SECURE",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
