import 'package:equatable/equatable.dart';

class SharedSpaceEntity extends Equatable {
  final String id;
  final String title;
  final String createdBy;
  final double totalAmount;
  final double paidAmount;
  final List<String> memberIds; // IDs of users in the space
  final DateTime createdAt;
  final bool isSettled;

  const SharedSpaceEntity({
    required this.id,
    required this.title,
    required this.createdBy,
    required this.totalAmount,
    this.paidAmount = 0,
    required this.memberIds,
    required this.createdAt,
    this.isSettled = false,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        createdBy,
        totalAmount,
        paidAmount,
        memberIds,
        createdAt,
        isSettled,
      ];
}
