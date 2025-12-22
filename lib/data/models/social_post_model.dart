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
  });

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
    };
  }
}
