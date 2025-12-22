import 'package:equatable/equatable.dart';

class SocialPostEntity extends Equatable {
  final String id;
  final String userId;
  final String userName;
  final String content;
  final String? mediaUrl;
  final String? userAvatarUrl;
  final DateTime timestamp;
  final int likes;
  final int comments;
  final bool isLiked;

  const SocialPostEntity({
    required this.id,
    required this.userId,
    required this.userName,
    required this.content,
    this.mediaUrl,
    this.userAvatarUrl,
    required this.timestamp,
    this.likes = 0,
    this.comments = 0,
    this.isLiked = false,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        userName,
        content,
        mediaUrl,
        userAvatarUrl,
        timestamp,
        likes,
        comments,
        isLiked,
      ];
}
