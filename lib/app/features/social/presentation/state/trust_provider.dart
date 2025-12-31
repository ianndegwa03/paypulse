import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paypulse/data/repositories/vouch_repository_impl.dart';
import 'package:paypulse/domain/entities/vouch_entity.dart';
import 'package:paypulse/app/features/auth/presentation/state/auth_notifier.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final vouchRepositoryProvider = Provider<VouchRepository>((ref) {
  final userId = ref.watch(authNotifierProvider).userId ?? '';
  return VouchRepositoryImpl(FirebaseFirestore.instance, userId);
});

final userVouchesProvider =
    StreamProvider.family<List<Vouch>, String>((ref, userId) {
  return ref.watch(vouchRepositoryProvider).getVouchesForUser(userId);
});

class TrustState {
  final int vouchCount;
  final bool isVouchedByMe;

  TrustState({required this.vouchCount, required this.isVouchedByMe});
}

final trustProvider = Provider.family<TrustState, String>((ref, userId) {
  final vouches = ref.watch(userVouchesProvider(userId)).value ?? [];
  final currentUserId = ref.watch(authNotifierProvider).userId;

  return TrustState(
    vouchCount: vouches.length,
    isVouchedByMe: vouches.any((v) => v.voucherId == currentUserId),
  );
});
