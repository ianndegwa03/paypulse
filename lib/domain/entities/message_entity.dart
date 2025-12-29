import 'package:equatable/equatable.dart';

enum MessageType { text, image, funds, system }

class MessageEntity extends Equatable {
  final String id;
  final String senderId;
  final String receiverId;
  final String content; // This will hold encrypted text or media paths
  final DateTime timestamp;
  final bool isRead;
  final MessageType type;
  final double? amount; // For funds transfers
  final String? status; // pending, completed, etc.

  const MessageEntity({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.timestamp,
    this.isRead = false,
    this.type = MessageType.text,
    this.amount,
    this.status,
  });

  @override
  List<Object?> get props => [
        id,
        senderId,
        receiverId,
        content,
        timestamp,
        isRead,
        type,
        amount,
        status
      ];

  MessageEntity copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? content,
    DateTime? timestamp,
    bool? isRead,
    MessageType? type,
    double? amount,
    String? status,
  }) {
    return MessageEntity(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      status: status ?? this.status,
    );
  }
}
