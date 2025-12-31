import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paypulse/core/theme/app_theme.dart';
import 'package:paypulse/core/theme/theme_provider.dart';
import 'package:paypulse/core/localization/app_localizations.dart';
import 'package:paypulse/core/localization/locale_manager.dart';
import 'package:paypulse/core/accessibility/accessibility_service.dart';
import 'package:paypulse/app/observers/app_bloc_observer.dart';
import 'package:paypulse/app/features/security/presentation/widgets/privacy_overlay_wrapper.dart';

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
  @override
  void initState() {
    super.initState();
    // Initialize accessibility service
    AccessibilityService.instance.initialize();

    // Initialize bloc observer
    AppBlocObserver.instance.initialize();
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
      theme: AppTheme.lightTheme(primaryColor: themeConfig.primaryColor),
      darkTheme: AppTheme.darkTheme(primaryColor: themeConfig.primaryColor),
      themeMode: themeConfig.mode,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: widget.routerConfig,
      builder: (context, child) =>
          PrivacyOverlayWrapper(child: child ?? const SizedBox.shrink()),
    );
  }
}
