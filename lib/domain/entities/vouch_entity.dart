import 'package:equatable/equatable.dart';

class Vouch extends Equatable {
  final String id;
  final String voucherId; // User who is vouching
  final String voucheeId; // User being vouched for
  final DateTime date;
  final String? comment;

  const Vouch({
    required this.id,
    required this.voucherId,
    required this.voucheeId,
    required this.date,
    this.comment,
  });

  @override
  List<Object?> get props => [id, voucherId, voucheeId, date, comment];
}
