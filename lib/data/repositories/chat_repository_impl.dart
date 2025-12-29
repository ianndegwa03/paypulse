import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:paypulse/core/errors/failures.dart';
import 'package:paypulse/core/services/encryption/encryption_service.dart';
import 'package:paypulse/domain/entities/chat_entity.dart';
import 'package:paypulse/domain/entities/message_entity.dart';
import 'package:paypulse/domain/repositories/chat_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatRepositoryImpl implements ChatRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final EncryptionService _encryptionService;

  ChatRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    required EncryptionService encryptionService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _encryptionService = encryptionService;

  @override
  Stream<List<ChatEntity>> getChats() {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return Stream.value([]);

    return _firestore
        .collection('chats')
        .where('participants', arrayContains: currentUserId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return ChatEntity(
          id: doc.id,
          participants: List<String>.from(data['participants']),
          isGroup: data['isGroup'] ?? false,
          groupName: data['groupName'],
          unreadCount:
              (data['unreadCount'] as Map<String, dynamic>?)?[currentUserId] ??
                  0,
        );
      }).toList();
    });
  }

  @override
  Stream<List<MessageEntity>> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      final messages = <MessageEntity>[];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final encryptedContent = data['content'] as String;
        final decryptedContent =
            await _encryptionService.decryptMessage(encryptedContent);

        messages.add(MessageEntity(
          id: doc.id,
          senderId: data['senderId'],
          receiverId: data['receiverId'] ?? '',
          content: decryptedContent,
          timestamp: (data['timestamp'] as Timestamp).toDate(),
          type: MessageType.values.firstWhere(
            (e) => e.toString() == data['type'],
            orElse: () => MessageType.text,
          ),
          amount: data['amount']?.toDouble(),
          isRead: data['isRead'] ?? false,
        ));
      }
      return messages;
    });
  }

  @override
  Future<Either<Failure, void>> sendMessage({
    required String chatId,
    required String content,
    required MessageType type,
    double? amount,
  }) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null)
        return Left(ServerFailure(message: 'User not authenticated'));

      final encryptedContent = await _encryptionService.encryptMessage(content);

      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add({
        'senderId': currentUserId,
        'content': encryptedContent,
        'type': type.toString(),
        'amount': amount,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      });

      await _firestore.collection('chats').doc(chatId).update({
        'updatedAt': FieldValue.serverTimestamp(),
        'lastMessageContent': encryptedContent,
      });

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ChatEntity>> createChat(List<String> participantIds,
      {bool isGroup = false, String? groupName}) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null)
        return Left(ServerFailure(message: 'User not authenticated'));

      final allParticipants = {...participantIds, currentUserId}.toList();

      final docRef = await _firestore.collection('chats').add({
        'participants': allParticipants,
        'isGroup': isGroup,
        'groupName': groupName,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'unreadCount': {for (var p in allParticipants) p: 0},
      });

      return Right(ChatEntity(
        id: docRef.id,
        participants: allParticipants,
        isGroup: isGroup,
        groupName: groupName,
      ));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead(String chatId) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null)
        return Left(ServerFailure(message: 'User not authenticated'));

      await _firestore.collection('chats').doc(chatId).update({
        'unreadCount.$currentUserId': 0,
      });

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
