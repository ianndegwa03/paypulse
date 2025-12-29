import 'package:go_router/go_router.dart';
import 'package:paypulse/app/features/auth/presentation/screens/login_screen.dart';
import 'package:paypulse/app/features/auth/presentation/screens/register_screen.dart';
import 'package:paypulse/app/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:paypulse/app/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:paypulse/app/features/dashboard/presentation/screens/settings/edit_profile_screen.dart';
import 'package:paypulse/app/features/dashboard/presentation/screens/settings/security_settings_screen.dart';
import 'package:paypulse/app/features/settings/presentation/screens/theme_settings_screen.dart';
import 'package:paypulse/app/features/social/presentation/screens/chat_list_screen.dart';
import 'package:paypulse/app/features/splash/presentation/screens/splash_screen.dart';
import 'package:paypulse/app/features/wallet/presentation/screens/send_money_screen.dart';
import 'package:paypulse/app/features/privacy/presentation/screens/privacy_settings_screen.dart';
import 'package:paypulse/app/features/dashboard/presentation/screens/profile_icon_screen.dart';
import 'package:paypulse/app/features/contacts/presentation/screens/contacts_list_screen.dart';
import 'package:paypulse/app/features/wallet/presentation/screens/connect_wallet_screen.dart';
import 'package:paypulse/app/features/wallet/presentation/screens/qr_scanner_screen.dart';
import 'package:paypulse/app/features/wallet/presentation/screens/my_qr_screen.dart';
import 'package:paypulse/app/features/wallet/presentation/screens/split_bill_screen.dart';
import 'package:paypulse/app/features/wallet/presentation/screens/transaction_history_screen.dart';
import 'package:paypulse/app/features/budgeting/presentation/screens/budgeting_dashboard_screen.dart';
import 'package:paypulse/app/features/bills/presentation/screens/bill_reminder_screen.dart';
import 'package:paypulse/app/features/dashboard/presentation/screens/profile_tab_screen.dart';
import 'package:paypulse/app/features/analytics/presentation/screens/premium_insights_screen.dart';
import 'package:paypulse/app/features/multicurrency/presentation/screens/multi_currency_wallet_screen.dart';
import 'package:paypulse/app/features/dashboard/presentation/screens/settings/identity_config_screen.dart';
import 'package:paypulse/app/features/dashboard/presentation/screens/settings/privacy_security_controls_screen.dart';
import 'package:paypulse/app/features/wallet/presentation/screens/create_ghost_card_screen.dart';
import 'package:paypulse/app/features/social/presentation/screens/secure_chat_screen.dart';
import 'package:paypulse/app/features/dashboard/presentation/screens/settings/personal_info_screen.dart';
import 'package:paypulse/app/features/dashboard/presentation/screens/settings/professional_profile_screen.dart';
import 'package:paypulse/app/features/wallet/presentation/screens/bank_integration_flow_screen.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class UserRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
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
        builder: (context, state) => const SecuritySettingsScreen(),
      ),
      GoRoute(
        path: '/theme-settings',
        builder: (context, state) => const ThemeSettingsScreen(),
      ),
      GoRoute(
        path: '/chats',
        builder: (context, state) => const ChatListScreen(),
      ),
      GoRoute(
        path: '/send-money',
        builder: (context, state) =>
            SendMoneyScreen(initialContact: state.extra as Contact?),
      ),
      GoRoute(
        path: '/profile-icons',
        builder: (context, state) => const ProfileIconScreen(),
      ),
      GoRoute(
        path: '/contacts',
        builder: (context, state) => const ContactsListScreen(),
      ),
      GoRoute(
        path: '/privacy-settings',
        builder: (context, state) => const PrivacySettingsScreen(),
      ),
      GoRoute(
        path: '/connect-wallet',
        builder: (context, state) => const ConnectWalletScreen(),
      ),
      GoRoute(
        path: '/qr-scan',
        builder: (context, state) => const QrScannerScreen(),
      ),
      GoRoute(
        path: '/my-qr',
        builder: (context, state) => const MyQrScreen(),
      ),
      GoRoute(
        path: '/split-bill',
        builder: (context, state) => const SplitBillScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileTabScreen(),
      ),
      GoRoute(
        path: '/transaction-history',
        builder: (context, state) => const TransactionHistoryScreen(),
      ),
      GoRoute(
        path: '/budgets',
        builder: (context, state) => const BudgetingDashboardScreen(),
      ),
      GoRoute(
        path: '/bills',
        builder: (context, state) => const BillReminderScreen(),
      ),
      GoRoute(
        path: '/premium-insights',
        builder: (context, state) => const PremiumInsightsScreen(),
      ),
      GoRoute(
        path: '/multi-currency',
        builder: (context, state) => const MultiCurrencyWalletScreen(),
      ),
      GoRoute(
        path: '/identity-config',
        builder: (context, state) => const IdentityConfigScreen(),
      ),
      GoRoute(
        path: '/privacy-controls',
        builder: (context, state) => const PrivacySecurityControlsScreen(),
      ),
      GoRoute(
        path: '/create-ghost-card',
        builder: (context, state) => const CreateGhostCardScreen(),
      ),
      GoRoute(
        path: '/secure-chat/:chatId',
        builder: (context, state) => SecureChatScreen(
          chatId: state.pathParameters['chatId']!,
          title:
              (state.extra as Map<String, dynamic>?)?['title'] ?? 'Secure Chat',
        ),
      ),
      GoRoute(
        path: '/personal-info',
        builder: (context, state) => const PersonalInfoScreen(),
      ),
      GoRoute(
        path: '/professional-profile',
        builder: (context, state) => const ProfessionalProfileScreen(),
      ),
      GoRoute(
        path: '/bank-integration-flow',
        builder: (context, state) => const BankIntegrationFlowScreen(),
      ),
    ],
  );
}
