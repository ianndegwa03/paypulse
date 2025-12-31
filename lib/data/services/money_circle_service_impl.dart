import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paypulse/domain/entities/money_circle_entity.dart';
import 'package:paypulse/domain/services/money_circle_service.dart';
import 'package:uuid/uuid.dart';

class MoneyCircleServiceImpl implements MoneyCircleService {
  final FirebaseFirestore _firestore;
  final _uuid = const Uuid();

  MoneyCircleServiceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<MoneyCircle> createCircle({
    required String name,
    required double contributionAmount,
    required CircleFrequency frequency,
    required String currencyCode,
    required String creatorId, // Added to pass from provider
  }) async {
    final id = _uuid.v4();
    final newCircle = MoneyCircle(
      id: id,
      name: name,
      contributionAmount: contributionAmount,
      frequency: frequency,
      currencyCode: currencyCode,
      nextPayoutDate: DateTime.now().add(const Duration(days: 30)),
      members: [
        MoneyCircleMember(
          userId: creatorId,
          displayName: 'You', // In real app, fetch display name
          payoutOrder: 1,
        ),
      ],
    );

    await _firestore
        .collection('money_circles')
        .doc(id)
        .set(_mapCircleToMap(newCircle));
    return newCircle;
  }

  @override
  Stream<List<MoneyCircle>> getUserCircles(String userId) {
    return _firestore
        .collection('money_circles')
        .where('memberIds', arrayContains: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => _mapMapToCircle(doc.id, doc.data()))
            .toList());
  }

  @override
  Future<void> joinCircle(
      String circleId, String userId, String displayName) async {
    final circleRef = _firestore.collection('money_circles').doc(circleId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(circleRef);
      if (!snapshot.exists) throw Exception('Circle not found');

      final data = snapshot.data()!;
      final List<dynamic> memberIds = List.from(data['memberIds'] ?? []);
      if (memberIds.contains(userId)) return;

      final List<dynamic> members = List.from(data['members'] ?? []);
      members.add({
        'userId': userId,
        'displayName': displayName,
        'payoutOrder': members.length + 1,
        'hasPaidCurrentCycle': false,
        'hasReceivedPayout': false,
      });
      memberIds.add(userId);

      transaction.update(circleRef, {
        'members': members,
        'memberIds': memberIds,
      });
    });
  }

  @override
  Future<MoneyCircle> contribute(String circleId, String userId) async {
    final circleRef = _firestore.collection('money_circles').doc(circleId);

    return await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(circleRef);
      if (!snapshot.exists) throw Exception('Circle not found');

      final data = snapshot.data()!;
      final List<dynamic> members = List.from(data['members'] ?? []);
      final index = members.indexWhere((m) => m['userId'] == userId);

      if (index != -1) {
        members[index]['hasPaidCurrentCycle'] = true;
        transaction.update(circleRef, {'members': members});
      }

      return _mapMapToCircle(circleId, {...data, 'members': members});
    });
  }

  @override
  Future<MoneyCircle> advanceRound(String circleId) async {
    final circleRef = _firestore.collection('money_circles').doc(circleId);

    return await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(circleRef);
      if (!snapshot.exists) throw Exception('Circle not found');

      final data = snapshot.data()!;
      final int currentRound = data['currentRound'] ?? 1;
      final int nextRound = currentRound + 1;
      final List<dynamic> members = List.from(data['members'] ?? []);

      final updatedMembers = members.map((m) {
        return {
          ...m,
          'hasPaidCurrentCycle': false,
          'hasReceivedPayout': m['payoutOrder'] < nextRound,
        };
      }).toList();

      final nextPayout = (data['nextPayoutDate'] as Timestamp)
          .toDate()
          .add(const Duration(days: 30));

      transaction.update(circleRef, {
        'currentRound': nextRound,
        'members': updatedMembers,
        'nextPayoutDate': Timestamp.fromDate(nextPayout),
      });

      return _mapMapToCircle(circleId, {
        ...data,
        'currentRound': nextRound,
        'members': updatedMembers,
        'nextPayoutDate': Timestamp.fromDate(nextPayout),
      });
    });
  }

  Map<String, dynamic> _mapCircleToMap(MoneyCircle circle) {
    return {
      'name': circle.name,
      'contributionAmount': circle.contributionAmount,
      'frequency': circle.frequency.name,
      'currencyCode': circle.currencyCode,
      'nextPayoutDate': Timestamp.fromDate(circle.nextPayoutDate),
      'currentRound': circle.currentRound,
      'memberIds': circle.members.map((m) => m.userId).toList(),
      'members': circle.members
          .map((m) => {
                'userId': m.userId,
                'displayName': m.displayName,
                'payoutOrder': m.payoutOrder,
                'hasPaidCurrentCycle': m.hasPaidCurrentCycle,
                'hasReceivedPayout': m.hasReceivedPayout,
              })
          .toList(),
    };
  }

  MoneyCircle _mapMapToCircle(String id, Map<String, dynamic> data) {
    return MoneyCircle(
      id: id,
      name: data['name'] ?? '',
      contributionAmount: (data['contributionAmount'] as num).toDouble(),
      frequency:
          CircleFrequency.values.firstWhere((e) => e.name == data['frequency']),
      currencyCode: data['currencyCode'] ?? 'USD',
      nextPayoutDate: (data['nextPayoutDate'] as Timestamp).toDate(),
      currentRound: data['currentRound'] ?? 1,
      members: (data['members'] as List).map((m) {
        final member = m as Map<String, dynamic>;
        return MoneyCircleMember(
          userId: member['userId'] ?? '',
          displayName: member['displayName'] ?? '',
          payoutOrder: member['payoutOrder'] ?? 1,
          hasPaidCurrentCycle: member['hasPaidCurrentCycle'] ?? false,
          hasReceivedPayout: member['hasReceivedPayout'] ?? false,
        );
      }).toList(),
    );
  }
}
