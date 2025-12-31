import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paypulse/domain/entities/community_post_entity.dart';

class CommunityPostModel extends CommunityPost {
  const CommunityPostModel({
    required super.id,
    required super.userId,
    required super.username,
    super.userProfileUrl,
    required super.content,
    required super.createdAt,
    super.likes,
    super.likedBy,
    super.financialAction,
    super.isGhost,
    super.attachmentUrls,
    super.poll,
    super.location,
    super.replySettings,
  });

  factory CommunityPostModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CommunityPostModel(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      username: data['username'] as String? ?? 'Anonymous',
      userProfileUrl: data['userProfileUrl'] as String?,
      content: data['content'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      likes: data['likes'] as int? ?? 0,
      likedBy: List<String>.from(data['likedBy'] ?? []),
      financialAction: data['financialAction'] as Map<String, dynamic>?,
      isGhost: data['isGhost'] as bool? ?? false,
      attachmentUrls: List<String>.from(data['attachmentUrls'] ?? []),
      poll: data['poll'] as Map<String, dynamic>?,
      location: data['location'] as Map<String, dynamic>?,
      replySettings: data['replySettings'] as String? ?? 'everyone',
    );
  }

  Map<String, dynamic> toDocument() {
    return {
      'userId': userId,
      'username': username,
      'userProfileUrl': userProfileUrl,
      'content': content,
      'createdAt': FieldValue.serverTimestamp(),
      'likes': likes,
      'likedBy': likedBy,
      'financialAction': financialAction,
      'isGhost': isGhost,
      'attachmentUrls': attachmentUrls,
      'poll': poll,
      'location': location,
      'replySettings': replySettings,
    };
  }

  static CommunityPostModel fromEntity(CommunityPost entity) {
    return CommunityPostModel(
      id: entity.id,
      userId: entity.userId,
      username: entity.username,
      userProfileUrl: entity.userProfileUrl,
      content: entity.content,
      createdAt: entity.createdAt,
      likes: entity.likes,
      likedBy: entity.likedBy,
      financialAction: entity.financialAction,
      isGhost: entity.isGhost,
      attachmentUrls: entity.attachmentUrls,
      poll: entity.poll,
      location: entity.location,
      replySettings: entity.replySettings,
    );
  }
}
