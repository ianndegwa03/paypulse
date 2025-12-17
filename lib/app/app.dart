import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paypulse/core/theme/app_theme.dart';
import 'package:paypulse/core/theme/theme_provider.dart';
import 'package:paypulse/core/localization/app_localizations.dart';
import 'package:paypulse/core/localization/locale_manager.dart';
import 'package:paypulse/core/accessibility/accessibility_service.dart';
import 'package:paypulse/app/observers/app_bloc_observer.dart';

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
    final themeMode = ref.watch(themeProvider);
    final locale = ref.watch(localeManagerProvider);

    return MaterialApp.router(
      title: 'PayPulse',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: widget.routerConfig, // Use injected config
      builder: (context, child) {
        // Apply text scaling for accessibility
        final mediaQueryData = MediaQuery.of(context);
        final scaledMediaQuery = mediaQueryData.copyWith(
          textScaler: AccessibilityService.instance.getTextScaler(
            mediaQueryData.textScaler,
          ),
        );

        return MediaQuery(
          data: scaledMediaQuery,
          child: child!,
        );
      },
    );
  }
}
