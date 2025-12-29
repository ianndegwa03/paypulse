import 'package:equatable/equatable.dart';

enum SplitStatus { pending, accepted, rejected, completed }

class SplitRequest extends Equatable {
  final String id;
  final String initiatorId;
  final String initiatorName;
  final double totalAmount;
  final double perPersonAmount;
  final String description;
  final DateTime createdAt;
  final Map<String, SplitStatus> participantStatuses; // userId -> status

  const SplitRequest({
    required this.id,
    required this.initiatorId,
    required this.initiatorName,
    required this.totalAmount,
    required this.perPersonAmount,
    required this.description,
    required this.createdAt,
    required this.participantStatuses,
  });

  bool get isFullyAccepted =>
      participantStatuses.values.every((s) => s == SplitStatus.accepted);

  @override
  List<Object?> get props => [
        id,
        initiatorId,
        initiatorName,
        totalAmount,
        perPersonAmount,
        description,
        createdAt,
        participantStatuses,
      ];

  SplitRequest copyWith({
    String? id,
    String? initiatorId,
    String? initiatorName,
    double? totalAmount,
    double? perPersonAmount,
    String? description,
    DateTime? createdAt,
    Map<String, SplitStatus>? participantStatuses,
  }) {
    return SplitRequest(
      id: id ?? this.id,
      initiatorId: initiatorId ?? this.initiatorId,
      initiatorName: initiatorName ?? this.initiatorName,
      totalAmount: totalAmount ?? this.totalAmount,
      perPersonAmount: perPersonAmount ?? this.perPersonAmount,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      participantStatuses: participantStatuses ?? this.participantStatuses,
    );
  }
}
