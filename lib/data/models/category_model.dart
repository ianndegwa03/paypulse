import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paypulse/domain/entities/category_entity.dart';

class CategoryModel extends Category {
  const CategoryModel({
    required super.id,
    required super.name,
  });

  factory CategoryModel.fromSnapshot(DocumentSnapshot snap) {
    return CategoryModel(
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
