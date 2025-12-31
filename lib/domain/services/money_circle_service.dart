import 'package:paypulse/domain/entities/money_circle_entity.dart';

abstract class MoneyCircleService {
  /// Create a new Money Circle
  Future<MoneyCircle> createCircle({
    required String name,
    required double contributionAmount,
    required CircleFrequency frequency,
    required String currencyCode,
    required String creatorId,
  });

  /// Get active circles for user
  Stream<List<MoneyCircle>> getUserCircles(String userId);

  /// Join a circle given an ID
  Future<void> joinCircle(String circleId, String userId, String displayName);

  /// Contribute to the current cycle
  Future<MoneyCircle> contribute(String circleId, String userId);

  /// Advance to next round
  Future<MoneyCircle> advanceRound(String circleId);
}
