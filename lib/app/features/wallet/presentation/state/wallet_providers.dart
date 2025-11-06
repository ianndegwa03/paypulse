import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:paypulse/domain/repositories/wallet_repository.dart';
import 'package:paypulse/app/features/wallet/presentation/state/wallet_notifier.dart';
import 'package:paypulse/app/features/wallet/presentation/state/wallet_state.dart';

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  return GetIt.instance<WalletRepository>();
});

final walletStateProvider = StateNotifierProvider<WalletNotifier, WalletState>((ref) {
  final walletRepository = ref.watch(walletRepositoryProvider);
  return WalletNotifier(walletRepository);
});
