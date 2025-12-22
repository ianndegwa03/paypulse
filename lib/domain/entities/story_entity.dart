import 'package:equatable/equatable.dart';

class StoryEntity extends Equatable {
  final String id;
  final String userId;
  final String userName;
  final String? userAvatarUrl;
  final String mediaUrl;
  final DateTime timestamp;
  final bool isViewed;

  const StoryEntity({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatarUrl,
    required this.mediaUrl,
    required this.timestamp,
    this.isViewed = false,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        userName,
        userAvatarUrl,
        mediaUrl,
        timestamp,
        isViewed,
      ];
}
