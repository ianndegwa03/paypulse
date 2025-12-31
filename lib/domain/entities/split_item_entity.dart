import 'package:equatable/equatable.dart';

class SplitItem extends Equatable {
  final String id;
  final String name;
  final double price;
  final List<String> assignedUserIds;

  const SplitItem({
    required this.id,
    required this.name,
    required this.price,
    this.assignedUserIds = const [],
  });

  SplitItem copyWith({
    String? id,
    String? name,
    double? price,
    List<String>? assignedUserIds,
  }) {
    return SplitItem(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      assignedUserIds: assignedUserIds ?? this.assignedUserIds,
    );
  }

  // Helper to calculate cost per person for this item
  double get costPerPerson =>
      assignedUserIds.isEmpty ? 0 : price / assignedUserIds.length;

  @override
  List<Object?> get props => [id, name, price, assignedUserIds];
}
