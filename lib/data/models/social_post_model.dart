import 'package:paypulse/domain/entities/social_post_entity.dart';

class SocialPostModel extends SocialPostEntity {
  const SocialPostModel({
    required super.id,
    required super.userId,
    required super.userName,
    required super.content,
    super.mediaUrl,
    super.userAvatarUrl,
    required super.timestamp,
    super.likes,
    super.comments,
    super.isLiked,
    super.shares,
    super.isVerified,
    super.type,
    super.totalAmount,
    super.collectedAmount,
    super.title,
  });

  @override
  SocialPostModel copyWith({
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
    return SocialPostModel(
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

  factory SocialPostModel.fromJson(Map<String, dynamic> json) {
    return SocialPostModel(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      userName: json['user_name'] as String? ?? 'Anonymous',
      content: json['content'] as String? ?? '',
      mediaUrl: json['media_url'] as String?,
      userAvatarUrl: json['user_avatar_url'] as String?,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      likes: json['likes'] as int? ?? 0,
      comments: json['comments'] as int? ?? 0,
      isLiked: json['is_liked'] as bool? ?? false,
      shares: json['shares'] as int? ?? 0,
      isVerified: json['is_verified'] as bool? ?? false,
      type: PostType.values.byName(json['type'] as String? ?? 'regular'),
      totalAmount: (json['total_amount'] as num?)?.toDouble(),
      collectedAmount: (json['collected_amount'] as num?)?.toDouble(),
      title: json['title'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'content': content,
      'media_url': mediaUrl,
      'user_avatar_url': userAvatarUrl,
      'timestamp': timestamp.toIso8601String(),
      'likes': likes,
      'comments': comments,
      'is_liked': isLiked,
      'shares': shares,
      'is_verified': isVerified,
      'type': type.name,
      'total_amount': totalAmount,
      'collected_amount': collectedAmount,
      'title': title,
    };
  }
}
