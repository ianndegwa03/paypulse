import 'package:equatable/equatable.dart';
import 'package:paypulse/domain/entities/enums.dart';

class BillEntity extends Equatable {
  final String id;
  final String title;
  final String payee;
  final double amount;
  final CurrencyType currency;
  final DateTime dueDate;
  final bool isPaid;
  final String? category;

  const BillEntity({
    required this.id,
    required this.title,
    required this.payee,
    required this.amount,
    required this.currency,
    required this.dueDate,
    this.isPaid = false,
    this.category,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        payee,
        amount,
        currency,
        dueDate,
        isPaid,
        category,
      ];
}
