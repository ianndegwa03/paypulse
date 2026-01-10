import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paypulse/domain/entities/chat_entity.dart';

class ChatState {
  final List<ChatEntity> chats;
  final bool isLoading;

  ChatState({
    required this.chats,
    this.isLoading = false,
  });

  ChatState copyWith({
    List<ChatEntity>? chats,
    bool? isLoading,
  }) {
    return ChatState(
      chats: chats ?? this.chats,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  ChatNotifier() : super(ChatState(chats: [])) {
    _loadMockChats();
  }

  void _loadMockChats() {
    state = state.copyWith(isLoading: true);
    // TODO: Link to real repository
    state = state.copyWith(
      chats: [
        const ChatEntity(
          id: '1',
          participants: ['system', 'user'],
          groupName: 'PayPulse Support',
          unreadCount: 1,
        ),
      ],
      isLoading: false,
    );
  }

  Future<void> createChat(List<String> participants,
      {String? groupName}) async {
    // Mock creation
    final newChat = ChatEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      participants: participants,
      groupName: groupName,
      isGroup: groupName != null,
    );
    state = state.copyWith(chats: [newChat, ...state.chats]);
  }
}

final chatNotifierProvider =
    StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier();
});
