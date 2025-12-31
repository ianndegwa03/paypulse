import 'package:equatable/equatable.dart';

class CommunityPost extends Equatable {
  final String id;
  final String userId;
  final String username;
  final String? userProfileUrl;
  final String content;
  final DateTime createdAt;
  final int likes;
  final List<String> likedBy;
  final Map<String, dynamic>? financialAction;
  final bool isGhost;
  final List<String> attachmentUrls;
  final Map<String, dynamic>? poll;
  final Map<String, dynamic>? location;
  final String replySettings;

  const CommunityPost({
    required this.id,
    required this.userId,
    required this.username,
    this.userProfileUrl,
    required this.content,
    required this.createdAt,
    this.likes = 0,
    this.likedBy = const [],
    this.financialAction,
    this.isGhost = false,
    this.attachmentUrls = const [],
    this.poll,
    this.location,
    this.replySettings = 'everyone',
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        username,
        userProfileUrl,
        content,
        createdAt,
        likes,
        likedBy,
        financialAction,
        isGhost,
        attachmentUrls,
        poll,
        location,
        replySettings,
      ];

  CommunityPost copyWith({
    String? id,
    String? userId,
    String? username,
    String? userProfileUrl,
    String? content,
    DateTime? createdAt,
    int? likes,
    List<String>? likedBy,
    Map<String, dynamic>? financialAction,
    bool? isGhost,
    List<String>? attachmentUrls,
    Map<String, dynamic>? poll,
    Map<String, dynamic>? location,
    String? replySettings,
  }) {
    return CommunityPost(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      userProfileUrl: userProfileUrl ?? this.userProfileUrl,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      likes: likes ?? this.likes,
      likedBy: likedBy ?? this.likedBy,
      financialAction: financialAction ?? this.financialAction,
      isGhost: isGhost ?? this.isGhost,
      attachmentUrls: attachmentUrls ?? this.attachmentUrls,
      poll: poll ?? this.poll,
      location: location ?? this.location,
      replySettings: replySettings ?? this.replySettings,
    );
  }
}
