import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paypulse/app/features/auth/presentation/state/auth_providers.dart';
import 'package:paypulse/app/features/auth/presentation/state/auth_state.dart';
import 'package:paypulse/app/features/auth/presentation/screens/login_screen.dart';
import 'package:paypulse/app/features/auth/presentation/screens/register_screen.dart';
import 'package:paypulse/app/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:paypulse/app/features/wallet/presentation/screens/add_transaction_screen.dart';
import 'package:paypulse/app/features/wallet/presentation/screens/transaction_details_screen.dart';
import 'package:paypulse/domain/entities/transaction_entity.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: GoRouterRefreshStream(
      ref.watch(authStateProvider.notifier).authStateChanges,
    ),
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => RegistrationScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      // ✅ Jules’ additions merged properly
      GoRoute(
        path: '/profile',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Profile Screen')),
        ),
      ),
      GoRoute(
        path: '/add-transaction',
        builder: (context, state) => const AddTransactionScreen(),
      ),
      GoRoute(
        path: '/transaction-details',
        builder: (context, state) {
          final transaction = state.extra as Transaction;
          return TransactionDetailsScreen(transaction: transaction);
        },
      ),
    ],
    redirect: (context, state) {
      final isAuthenticated = authState is Authenticated;
      final isLoggingIn =
          state.uri.toString() == '/login' || state.uri.toString() == '/register';

      if (!isAuthenticated && !isLoggingIn) {
        return '/login';
      }

      if (isAuthenticated && isLoggingIn) {
        return '/dashboard';
      }

      return null;
    },
  );
});

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
