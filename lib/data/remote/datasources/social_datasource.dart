import 'package:paypulse/data/models/social_post_model.dart';

abstract class SocialDataSource {
  Future<List<SocialPostModel>> getFeed();
  Future<void> createPost(String content);
  Future<void> likePost(String postId);
}

class SocialDataSourceImpl implements SocialDataSource {
  @override
  Future<List<SocialPostModel>> getFeed() async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 600));
    return [
      SocialPostModel(
        id: '1',
        userId: 'u1',
        userName: 'Alice',
        content: 'Just reached my savings goal for the new car! #PayPulse',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        likes: 12,
        comments: 3,
        isLiked: true,
      ),
      SocialPostModel(
        id: '2',
        userId: 'u2',
        userName: 'Bob',
        content:
            'The investment features in this app are game changing. Highly recommend!',
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        likes: 25,
        comments: 6,
      ),
    ];
  }

  @override
  Future<void> createPost(String content) async {
    await Future.delayed(const Duration(milliseconds: 1000));
  }

  @override
  Future<void> likePost(String postId) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }
}
