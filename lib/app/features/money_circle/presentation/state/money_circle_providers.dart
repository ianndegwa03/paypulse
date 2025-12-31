import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paypulse/data/services/money_circle_service_impl.dart';
import 'package:paypulse/domain/entities/money_circle_entity.dart';
import 'package:paypulse/domain/services/money_circle_service.dart';

import 'package:paypulse/app/features/auth/presentation/state/auth_notifier.dart';

final moneyCircleServiceProvider = Provider<MoneyCircleService>((ref) {
  return MoneyCircleServiceImpl();
});

final userCirclesProvider = StreamProvider<List<MoneyCircle>>((ref) {
  final userId = ref.watch(authNotifierProvider).userId;
  if (userId == null) return Stream.value([]);
  final service = ref.watch(moneyCircleServiceProvider);
  return service.getUserCircles(userId);
});
