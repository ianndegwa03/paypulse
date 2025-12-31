import 'package:equatable/equatable.dart';

enum CircleFrequency { weekly, monthly }

enum CircleStatus { active, completed, paused }

class MoneyCircleMember extends Equatable {
  final String userId;
  final String displayName;
  final bool hasPaidCurrentCycle;
  final bool hasReceivedPayout;
  final int payoutOrder; // 1-based index

  const MoneyCircleMember({
    required this.userId,
    required this.displayName,
    this.hasPaidCurrentCycle = false,
    this.hasReceivedPayout = false,
    required this.payoutOrder,
  });

  MoneyCircleMember copyWith({
    String? userId,
    String? displayName,
    bool? hasPaidCurrentCycle,
    bool? hasReceivedPayout,
    int? payoutOrder,
  }) {
    return MoneyCircleMember(
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      hasPaidCurrentCycle: hasPaidCurrentCycle ?? this.hasPaidCurrentCycle,
      hasReceivedPayout: hasReceivedPayout ?? this.hasReceivedPayout,
      payoutOrder: payoutOrder ?? this.payoutOrder,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        displayName,
        hasPaidCurrentCycle,
        hasReceivedPayout,
        payoutOrder
      ];
}

class MoneyCircle extends Equatable {
  final String id;
  final String name;
  final double contributionAmount; // Per person per cycle
  final CircleFrequency frequency;
  final CircleStatus status;
  final int currentRound;
  final DateTime nextPayoutDate;
  final List<MoneyCircleMember> members;
  final String currencyCode;

  const MoneyCircle({
    required this.id,
    required this.name,
    required this.contributionAmount,
    required this.frequency,
    this.status = CircleStatus.active,
    this.currentRound = 1,
    required this.nextPayoutDate,
    required this.members,
    required this.currencyCode,
  });

  double get potAmount => contributionAmount * members.length;

  MoneyCircleMember? get currentRecipient => members
      .cast<MoneyCircleMember?>()
      .firstWhere((m) => m?.payoutOrder == currentRound, orElse: () => null);

  MoneyCircle copyWith({
    String? id,
    String? name,
    double? contributionAmount,
    CircleFrequency? frequency,
    CircleStatus? status,
    int? currentRound,
    DateTime? nextPayoutDate,
    List<MoneyCircleMember>? members,
    String? currencyCode,
  }) {
    return MoneyCircle(
      id: id ?? this.id,
      name: name ?? this.name,
      contributionAmount: contributionAmount ?? this.contributionAmount,
      frequency: frequency ?? this.frequency,
      status: status ?? this.status,
      currentRound: currentRound ?? this.currentRound,
      nextPayoutDate: nextPayoutDate ?? this.nextPayoutDate,
      members: members ?? this.members,
      currencyCode: currencyCode ?? this.currencyCode,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        contributionAmount,
        frequency,
        status,
        currentRound,
        nextPayoutDate,
        members,
        currencyCode
      ];
}
