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
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:paypulse/app/features/dashboard/presentation/screens/pulse_detail_screen.dart';
import 'package:paypulse/data/models/community_post_model.dart';
import 'package:paypulse/app/features/dashboard/presentation/screens/notifications_screen.dart';
import 'package:paypulse/app/features/dashboard/presentation/screens/goals_screen.dart';
import 'package:paypulse/app/features/analytics/presentation/screens/analytics_screen.dart';
import 'package:paypulse/app/features/settings/presentation/screens/privacy_settings_screen.dart';
import 'package:paypulse/app/features/split_bill/presentation/screens/split_bill_screen.dart';
import 'package:paypulse/app/features/money_circle/presentation/screens/money_circle_screen.dart';
import 'package:paypulse/app/features/pro/presentation/screens/invoice_generator_screen.dart';
import 'package:paypulse/app/features/cards/presentation/screens/virtual_cards_screen.dart';
import 'package:paypulse/app/features/multicurrency/presentation/screens/currency_trends_screen.dart';
import 'package:paypulse/app/features/money_circle/presentation/screens/create_circle_screen.dart';
import 'package:paypulse/app/features/auth/presentation/screens/auth_selection_screen.dart';

class UserRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
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
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/edit-profile',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/security-settings',
        builder: (context, state) => const SecurityPrivacyScreen(),
      ),
      GoRoute(
        path: '/theme-settings',
        builder: (context, state) => const ThemeSettingsScreen(),
      ),
      GoRoute(
        path: '/send-money',
        builder: (context, state) =>
            SendMoneyScreen(initialContact: state.extra as Contact?),
      ),
      GoRoute(
        path: '/contacts',
        builder: (context, state) => const ContactsListScreen(),
      ),
      GoRoute(
        path: '/transaction-history',
        builder: (context, state) => const TransactionHistoryScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileTabScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/goals',
        builder: (context, state) => const GoalsScreen(),
      ),
      GoRoute(
        path: '/scan',
        builder: (context, state) => Scaffold(
          appBar: AppBar(title: const Text("Scan QR")),
          body: const Center(child: Text("QR Scanner coming soon")),
        ),
      ),
      GoRoute(
        path: '/link-card',
        builder: (context, state) => const LinkCardScreen(),
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
        path: '/pulse-detail',
        builder: (context, state) {
          final post = state.extra as CommunityPostModel;
          return PulseDetailScreen(post: post);
        },
      ),
      GoRoute(
        path: '/split-bill',
        builder: (context, state) => const SplitBillScreen(),
      ),
      GoRoute(
        path: '/money-circle',
        builder: (context, state) => const MoneyCircleScreen(),
      ),
      GoRoute(
        path: '/create-money-circle',
        builder: (context, state) => const CreateCircleScreen(),
      ),
      GoRoute(
        path: '/invoice-generator',
        builder: (context, state) => const InvoiceGeneratorScreen(),
      ),
      GoRoute(
        path: '/virtual-cards',
        builder: (context, state) => const VirtualCardsScreen(),
      ),
      GoRoute(
        path: '/analytics',
        builder: (context, state) => const AnalyticsScreen(),
      ),
      GoRoute(
        path: '/privacy-transparency',
        builder: (context, state) => const PrivacySettingsScreen(),
      ),
      GoRoute(
        path: '/currency-trends',
        builder: (context, state) => const CurrencyTrendsScreen(),
      ),
      GoRoute(
        path: '/auth-selection',
        builder: (context, state) => const AuthSelectionScreen(),
      ),
    ],
  );
}
