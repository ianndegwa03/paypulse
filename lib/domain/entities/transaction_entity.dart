import 'package:equatable/equatable.dart';

class Transaction extends Equatable {
  final String id;
  final double amount;
  final String description;
  final DateTime date;
  final String categoryId;
  final String paymentMethodId;

  const Transaction({
    required this.id,
    required this.amount,
    required this.description,
    required this.date,
    required this.categoryId,
    required this.paymentMethodId,
  });

  @override
  List<Object?> get props => [id, amount, description, date, categoryId, paymentMethodId];
}
