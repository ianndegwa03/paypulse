import 'package:equatable/equatable.dart';

class PaymentMethod extends Equatable {
  final String id;
  final String name;

  const PaymentMethod({
    required this.id,
    required this.name,
  });

  @override
  List<Object?> get props => [id, name];
}
