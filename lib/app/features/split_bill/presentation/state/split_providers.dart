import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paypulse/data/services/split_service_impl.dart';
import 'package:paypulse/domain/services/split_service.dart';

final splitServiceProvider = Provider<SplitService>((ref) {
  return SplitServiceImpl();
});

final splitBillIdProvider = StateProvider<String?>((ref) => null);

final currentSplitBillProvider = StreamProvider.autoDispose((ref) {
  final service = ref.watch(splitServiceProvider);
  final id = ref.watch(splitBillIdProvider);

  if (id == null) return Stream.value(null);
  return service.getBillStream(id);
});
