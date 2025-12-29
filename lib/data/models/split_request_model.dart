import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paypulse/domain/entities/split_request_entity.dart';

class SplitRequestModel extends SplitRequest {
  const SplitRequestModel({
    required super.id,
    required super.initiatorId,
    required super.initiatorName,
    required super.totalAmount,
    required super.perPersonAmount,
    required super.description,
    required super.createdAt,
    required super.participantStatuses,
  });

  factory SplitRequestModel.fromEntity(SplitRequest entity) {
    return SplitRequestModel(
      id: entity.id,
      initiatorId: entity.initiatorId,
      initiatorName: entity.initiatorName,
      totalAmount: entity.totalAmount,
      perPersonAmount: entity.perPersonAmount,
      description: entity.description,
      createdAt: entity.createdAt,
      participantStatuses: entity.participantStatuses,
    );
  }

  factory SplitRequestModel.fromMap(String id, Map<String, dynamic> map) {
    return SplitRequestModel(
      id: id,
      initiatorId: map['initiatorId'] ?? '',
      initiatorName: map['initiatorName'] ?? '',
      totalAmount: (map['totalAmount'] ?? 0.0).toDouble(),
      perPersonAmount: (map['perPersonAmount'] ?? 0.0).toDouble(),
      description: map['description'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      participantStatuses:
          (map['participantStatuses'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, SplitStatus.values.byName(value)),
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'initiatorId': initiatorId,
      'initiatorName': initiatorName,
      'totalAmount': totalAmount,
      'perPersonAmount': perPersonAmount,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'participantStatuses':
          participantStatuses.map((key, value) => MapEntry(key, value.name)),
    };
  }
}
