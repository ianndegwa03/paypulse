import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paypulse/app/di/injector.dart';
import 'package:paypulse/domain/entities/chat_entity.dart';
import 'package:paypulse/domain/entities/message_entity.dart';
import 'package:paypulse/domain/repositories/chat_repository.dart';
import 'package:paypulse/data/repositories/chat_repository_impl.dart';
import 'package:paypulse/core/services/encryption/encryption_service.dart';
import 'package:paypulse/core/services/biometric/biometric_service.dart';

class ChatState {
  final List<ChatEntity> chats;
  final List<MessageEntity> messages;
  final bool isLoading;
  final String? errorMessage;

  ChatState({
    this.chats = const [],
    this.messages = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  ChatState copyWith({
    List<ChatEntity>? chats,
    List<MessageEntity>? messages,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ChatState(
      chats: chats ?? this.chats,
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  final ChatRepository _repository;

  ChatNotifier({required ChatRepository repository})
      : _repository = repository,
        super(ChatState()) {
    _listenToChats();
  }

  void _listenToChats() {
    _repository.getChats().listen((chats) {
      state = state.copyWith(chats: chats);
    });
  }

  void listenToMessages(String chatId) {
    state = state.copyWith(isLoading: true, messages: []);
    _repository.getMessages(chatId).listen((messages) {
      state = state.copyWith(messages: messages, isLoading: false);
    });
  }

  Future<void> sendMessage({
    required String chatId,
    required String content,
    MessageType type = MessageType.text,
    double? amount,
  }) async {
    final result = await _repository.sendMessage(
      chatId: chatId,
      content: content,
      type: type,
      amount: amount,
    );

    result.fold(
      (failure) => state = state.copyWith(errorMessage: failure.message),
      (_) => null,
    );
  }

  // This method is likely intended for a UI widget, not a StateNotifier.
  // For a StateNotifier, you would typically update the state directly.
  // Keeping it as provided in the instruction, but noting its typical context.
  Future<bool> authenticateForChatVault() async {
    try {
      final biometricService = getIt<BiometricService>();
      final didAuthenticate = await biometricService.authenticate(
        reason: 'Please authenticate to enter the Chat Vault',
      );
      // In a StateNotifier, you would update the state based on authentication result
      // For example: state = state.copyWith(isChatVaultUnlocked: didAuthenticate);
      return didAuthenticate;
    } catch (e) {
      // Handle biometric service errors, e.g., not available
      // For now, assuming it unlocks if biometrics fail (as per original snippet's logic)
      // In a real app, you might want to show an error or fallback to PIN.
      return true; // Or false, depending on desired fallback behavior
    }
  }

  Future<void> createChat(List<String> participantIds,
      {String? groupName}) async {
    final result = await _repository.createChat(participantIds,
        isGroup: groupName != null, groupName: groupName);

    result.fold(
      (failure) => state = state.copyWith(errorMessage: failure.message),
      (chat) => null,
    );
  }
}

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepositoryImpl(encryptionService: getIt<EncryptionService>());
});

final chatNotifierProvider =
    StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier(repository: ref.watch(chatRepositoryProvider));
});
