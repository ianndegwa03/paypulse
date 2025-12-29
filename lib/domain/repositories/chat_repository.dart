import 'package:dartz/dartz.dart';
import 'package:paypulse/core/errors/failures.dart';
import 'package:paypulse/domain/entities/chat_entity.dart';
import 'package:paypulse/domain/entities/message_entity.dart';

abstract class ChatRepository {
  Stream<List<ChatEntity>> getChats();

  Stream<List<MessageEntity>> getMessages(String chatId);

  Future<Either<Failure, void>> sendMessage({
    required String chatId,
    required String content,
    required MessageType type,
    double? amount,
  });

  Future<Either<Failure, ChatEntity>> createChat(List<String> participantIds,
      {bool isGroup = false, String? groupName});

  Future<Either<Failure, void>> markAsRead(String chatId);
}
