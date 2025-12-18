import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paypulse/domain/entities/payment_method_entity.dart';

class PaymentMethodModel extends PaymentMethod {
  const PaymentMethodModel({
    required super.id,
    required super.name,
  });

  factory PaymentMethodModel.fromSnapshot(DocumentSnapshot snap) {
    return PaymentMethodModel(
      id: snap.id,
      name: snap['name'],
    );
  }

  Map<String, dynamic> toDocument() {
    return {
      'name': name,
    };
  }
}
