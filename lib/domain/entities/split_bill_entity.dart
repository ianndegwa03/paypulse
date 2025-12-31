import 'package:equatable/equatable.dart';
import 'package:paypulse/domain/entities/split_item_entity.dart';
import 'package:paypulse/domain/entities/split_participant_entity.dart';

class SplitBill extends Equatable {
  final String id;
  final String creatorId;
  final String title;
  final double totalAmount;
  final String currencyCode;
  final DateTime date;
  final List<SplitItem> items;
  final List<SplitParticipant> participants;
  final bool isSettled;

  const SplitBill({
    required this.id,
    required this.creatorId,
    required this.title,
    required this.totalAmount,
    required this.currencyCode,
    required this.date,
    this.items = const [],
    this.participants = const [],
    this.isSettled = false,
  });

  SplitBill copyWith({
    String? id,
    String? creatorId,
    String? title,
    double? totalAmount,
    String? currencyCode,
    DateTime? date,
    List<SplitItem>? items,
    List<SplitParticipant>? participants,
    bool? isSettled,
  }) {
    return SplitBill(
      id: id ?? this.id,
      creatorId: creatorId ?? this.creatorId,
      title: title ?? this.title,
      totalAmount: totalAmount ?? this.totalAmount,
      currencyCode: currencyCode ?? this.currencyCode,
      date: date ?? this.date,
      items: items ?? this.items,
      participants: participants ?? this.participants,
      isSettled: isSettled ?? this.isSettled,
    );
  }

  /// Calculate total assigned amount
  double get totalAssigned {
    return items.fold(0.0, (sum, item) => sum + item.price);
  }

  /// Calculate amount remaining to be assigned
  double get remainingAmount => totalAmount - totalAssigned;

  @override
  List<Object?> get props => [
        id,
        creatorId,
        title,
        totalAmount,
        currencyCode,
        date,
        items,
        participants,
        isSettled,
      ];
}
