import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:paypulse/core/theme/design_system_v2.dart';
import 'package:paypulse/core/theme/theme_provider.dart';
import 'package:paypulse/core/localization/app_localizations.dart';
import 'package:paypulse/core/localization/locale_manager.dart';
import 'package:paypulse/core/accessibility/accessibility_service.dart';
import 'package:paypulse/app/observers/app_bloc_observer.dart';
import 'package:paypulse/app/features/security/presentation/widgets/privacy_overlay_wrapper.dart';
import 'package:paypulse/core/widgets/confetti_overlay.dart';
import 'package:paypulse/core/services/shake_service.dart';

class PayPulseApp extends ConsumerStatefulWidget {
  final RouterConfig<Object> routerConfig;

  const PayPulseApp({
    super.key,
    required this.routerConfig,
  });

  @override
  ConsumerState<PayPulseApp> createState() => _PayPulseAppState();
}

class _PayPulseAppState extends ConsumerState<PayPulseApp> {
  final ShakeService _shakeService = ShakeService();
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    // Initialize accessibility service
    AccessibilityService.instance.initialize();

    // Initialize bloc observer
    AppBlocObserver.instance.initialize();

    // Initialize shake-to-pay listener
    _shakeService.startListening(() {
      // Navigate to send money on shake
      final context = _navigatorKey.currentContext;
      if (context != null) {
        context.push('/send-money');
      }
    });
  }

  @override
  void dispose() {
    _shakeService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeConfig = ref.watch(themeProvider);
    final locale = ref.watch(localeManagerProvider);

    // Use a minimal, unmodified MediaQuery to avoid platform-specific
    // input/keyboard crashes related to advanced TextScaler APIs.
    return MaterialApp.router(
      title: 'PayPulse',
      debugShowCheckedModeBanner: false,
      theme: PulseDesign.lightTheme,
      darkTheme: PulseDesign.darkTheme,
      themeMode: themeConfig.mode,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: widget.routerConfig,
      builder: (context, child) => ConfettiOverlay(
        child: PrivacyOverlayWrapper(child: child ?? const SizedBox.shrink()),
      ),
    );
  }
}
