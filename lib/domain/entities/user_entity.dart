import 'package:equatable/equatable.dart';

/// A class that represents an authenticated user.
class User extends Equatable {
  final String id;
  final String email;
  final String? name;

  const User({
    required this.id,
    required this.email,
    this.name,
  });

  @override
  List<Object?> get props => [id, email, name];
}
