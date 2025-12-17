import 'package:paypulse/domain/entities/bill_entity.dart';
import 'package:paypulse/domain/entities/enums.dart';

class BillModel extends BillEntity {
  const BillModel({
    required super.id,
    required super.title,
    required super.payee,
    required super.amount,
    required super.currency,
    required super.dueDate,
    super.isPaid,
    super.category,
  });

  factory BillModel.fromJson(Map<String, dynamic> json) {
    return BillModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      payee: json['payee'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: CurrencyType.values.firstWhere(
        (e) => e.name == (json['currency'] as String? ?? 'USD'),
        orElse: () => CurrencyType.USD,
      ),
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'] as String)
          : DateTime.now(),
      isPaid: json['is_paid'] as bool? ?? false,
      category: json['category'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'payee': payee,
      'amount': amount,
      'currency': currency.name,
      'due_date': dueDate.toIso8601String(),
      'is_paid': isPaid,
      'category': category,
    };
  }
}
