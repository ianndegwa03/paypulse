import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paypulse/data/services/pro_service_impl.dart';
import 'package:paypulse/domain/entities/pro_profile_entity.dart';
import 'package:paypulse/domain/services/pro_service.dart';
import 'package:paypulse/app/features/auth/presentation/state/auth_notifier.dart';

final proServiceProvider = Provider<ProService>((ref) {
  return ProServiceImpl();
});

final proModeProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(proServiceProvider);
  return service.getProModeStream();
});

final proProfileProvider = FutureProvider<ProProfile?>((ref) async {
  final userId = ref.watch(authNotifierProvider).userId;
  if (userId == null) return null;
  final service = ref.watch(proServiceProvider);
  return service.getProProfile(userId);
});
