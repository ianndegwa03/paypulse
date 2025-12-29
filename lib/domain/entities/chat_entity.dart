import 'package:equatable/equatable.dart';
import 'package:paypulse/domain/entities/message_entity.dart';

class ChatEntity extends Equatable {
  final String id;
  final List<String> participants;
  final MessageEntity? lastMessage;
  final int unreadCount;
  final bool isGroup;
  final String? groupName;
  final String? groupImageUrl;

  const ChatEntity({
    required this.id,
    required this.participants,
    this.lastMessage,
    this.unreadCount = 0,
    this.isGroup = false,
    this.groupName,
    this.groupImageUrl,
  });

  @override
  List<Object?> get props => [
        id,
        participants,
        lastMessage,
        unreadCount,
        isGroup,
        groupName,
        groupImageUrl
      ];

  ChatEntity copyWith({
    String? id,
    List<String>? participants,
    MessageEntity? lastMessage,
    int? unreadCount,
    bool? isGroup,
    String? groupName,
    String? groupImageUrl,
  }) {
    return ChatEntity(
      id: id ?? this.id,
      participants: participants ?? this.participants,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      isGroup: isGroup ?? this.isGroup,
      groupName: groupName ?? this.groupName,
      groupImageUrl: groupImageUrl ?? this.groupImageUrl,
    );
  }
}
