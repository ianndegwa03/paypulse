import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:paypulse/app/features/auth/presentation/screens/login_screen.dart';
import 'package:paypulse/app/features/auth/presentation/screens/register_screen.dart';
import 'package:paypulse/app/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:paypulse/app/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:paypulse/app/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:paypulse/app/features/dashboard/presentation/screens/settings/edit_profile_screen.dart';
import 'package:paypulse/app/features/settings/presentation/screens/theme_settings_screen.dart';
import 'package:paypulse/app/features/splash/presentation/screens/splash_screen.dart';
import 'package:paypulse/app/features/wallet/presentation/screens/send_money_screen.dart';
import 'package:paypulse/app/features/security_privacy/presentation/screens/security_privacy_screen.dart';
import 'package:paypulse/app/features/contacts/presentation/screens/contacts_list_screen.dart';
import 'package:paypulse/app/features/wallet/presentation/screens/transaction_history_screen.dart';
import 'package:paypulse/app/features/dashboard/presentation/screens/profile_tab_screen.dart';
import 'package:paypulse/app/features/wallet/presentation/screens/link_card_screen.dart';
import 'package:paypulse/app/features/auth/presentation/screens/pin_setup_screen.dart';
import 'package:paypulse/app/features/auth/presentation/screens/pin_login_screen.dart';
import 'package:paypulse/app/features/analytics/presentation/screens/analytics_screen.dart'
    deferred as premium_insights;
import 'package:paypulse/app/features/multicurrency/presentation/screens/multi_currency_wallet_screen.dart';
import 'package:paypulse/app/features/cards/presentation/screens/virtual_cards_screen.dart';
import 'package:paypulse/app/features/social/presentation/screens/chat_list_screen.dart';
import 'package:paypulse/app/features/admin/presentation/screens/admin_dashboard_screen.dart'
    deferred as admin_dashboard;

class UserRouter {
  static final router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/pin-setup',
        builder: (context, state) => const PinSetupScreen(),
      ),
      GoRoute(
        path: '/pin-login',
        builder: (context, state) => const PinLoginScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/edit-profile',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/theme-settings',
        builder: (context, state) => const ThemeSettingsScreen(),
      ),
      GoRoute(
        path: '/send-money',
        builder: (context, state) => const SendMoneyScreen(),
      ),
      GoRoute(
        path: '/privacy-controls',
        builder: (context, state) => const SecurityPrivacyScreen(),
      ),
      GoRoute(
        path: '/contacts',
        builder: (context, state) => const ContactsListScreen(),
      ),
      GoRoute(
        path: '/transactions',
        builder: (context, state) => const TransactionHistoryScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileTabScreen(),
      ),
      GoRoute(
        path: '/link-card',
        builder: (context, state) => const LinkCardScreen(),
      ),
      GoRoute(
        path: '/multi-currency',
        builder: (context, state) => const MultiCurrencyWalletScreen(),
      ),
      GoRoute(
        path: '/cards',
        builder: (context, state) => const VirtualCardsScreen(),
      ),
      GoRoute(
        path: '/messages',
        builder: (context, state) => const ChatListScreen(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => _deferredWidget(
          admin_dashboard.loadLibrary(),
          () => admin_dashboard.AdminDashboardScreen(),
        ),
      ),
      GoRoute(
        path: '/analytics',
        builder: (context, state) => _deferredWidget(
          premium_insights.loadLibrary(),
          () => premium_insights.AnalyticsScreen(),
        ),
      ),
    ],
  );

  static Widget _deferredWidget(
      Future<void> loading, Widget Function() builder) {
    return FutureBuilder(
      future: loading,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return builder();
        }
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
