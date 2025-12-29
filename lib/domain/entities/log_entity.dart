import 'package:equatable/equatable.dart';

class LogEntity extends Equatable {
  final String id;
  final String message;
  final String type; // INFO, WARN, ERROR, SUCCESS
  final DateTime timestamp;
  final String? userId;

  const LogEntity({
    required this.id,
    required this.message,
    required this.type,
    required this.timestamp,
    this.userId,
  });

  @override
  List<Object?> get props => [id, message, type, timestamp, userId];
}
