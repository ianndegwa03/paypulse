import 'package:equatable/equatable.dart';

class SocialPostEntity extends Equatable {
  final String id;
  final String userId;
  final String userName;
  final String content;
  final DateTime timestamp;
  final int likes;
  final int comments;
  final bool isLiked;

  const SocialPostEntity({
    required this.id,
    required this.userId,
    required this.userName,
    required this.content,
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
        timestamp,
        likes,
        comments,
        isLiked,
      ];
}
