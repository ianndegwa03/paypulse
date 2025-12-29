import 'package:equatable/equatable.dart';

enum PostType {
  regular,
  splitRequest,
  sharedTransaction,
  spendingGoal,
  fundraiser,
  poll,
  marketplace,
  investment,
  announcement,
}

enum FundraiserStatus { active, completed, cancelled }

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
  final int shares;
  final bool isVerified;

  final PostType type;
  final double? totalAmount;
  final double? collectedAmount;
  final String? title;

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
    this.shares = 0,
    this.isVerified = false,
    this.type = PostType.regular,
    this.totalAmount,
    this.collectedAmount,
    this.title,
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
        shares,
        isVerified,
        type,
        totalAmount,
        collectedAmount,
        title,
      ];

  SocialPostEntity copyWith({
    String? id,
    String? userId,
    String? userName,
    String? content,
    String? mediaUrl,
    String? userAvatarUrl,
    DateTime? timestamp,
    int? likes,
    int? comments,
    bool? isLiked,
    int? shares,
    bool? isVerified,
    PostType? type,
    double? totalAmount,
    double? collectedAmount,
    String? title,
  }) {
    return SocialPostEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      content: content ?? this.content,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      userAvatarUrl: userAvatarUrl ?? this.userAvatarUrl,
      timestamp: timestamp ?? this.timestamp,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      isLiked: isLiked ?? this.isLiked,
      shares: shares ?? this.shares,
      isVerified: isVerified ?? this.isVerified,
      type: type ?? this.type,
      totalAmount: totalAmount ?? this.totalAmount,
      collectedAmount: collectedAmount ?? this.collectedAmount,
      title: title ?? this.title,
    );
  }

  double get progressPercentage {
    if (totalAmount == null || totalAmount == 0) return 0;
    return ((collectedAmount ?? 0) / totalAmount!) * 100;
  }
}
