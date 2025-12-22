import 'package:paypulse/data/models/social_post_model.dart';
import 'package:paypulse/core/services/local_storage/storage_service.dart';

abstract class SocialDataSource {
  Future<List<SocialPostModel>> getFeed();
  Future<void> createPost(String content);
  Future<void> likePost(String postId);
}

class SocialDataSourceImpl implements SocialDataSource {
  final StorageService storageService;
  static const String _feedKey = 'social_feed_data';

  SocialDataSourceImpl(this.storageService);

  @override
  Future<List<SocialPostModel>> getFeed() async {
    // Try to load from storage
    final List<dynamic>? storedList = await storageService.getList(_feedKey);

    if (storedList != null && storedList.isNotEmpty) {
      try {
        return storedList
            .map((e) => SocialPostModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      } catch (e) {
        // Fallback if parsing fails
      }
    }

    // Seed Data (Simulated Real Initial Data)
    final seedData = [
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

    await _saveFeed(seedData);
    return seedData;
  }

  Future<void> _saveFeed(List<SocialPostModel> feed) async {
    final List<Map<String, dynamic>> jsonList =
        feed.map((e) => e.toJson()).toList();
    await storageService.saveList(_feedKey, jsonList);
  }

  @override
  Future<void> createPost(String content) async {
    final currentFeed = await getFeed();
    final newPost = SocialPostModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: 'current_user', // TODO: Get actual user ID
      userName: 'You', // TODO: Get actual user name
      content: content,
      timestamp: DateTime.now(),
      likes: 0,
      comments: 0,
    );

    final updatedFeed = [newPost, ...currentFeed];
    await _saveFeed(updatedFeed);
  }

  @override
  Future<void> likePost(String postId) async {
    final currentFeed = await getFeed();
    final updatedFeed = currentFeed.map((post) {
      if (post.id == postId) {
        final isLiked = !post.isLiked;
        return SocialPostModel(
          id: post.id,
          userId: post.userId,
          userName: post.userName,
          content: post.content,
          timestamp: post.timestamp,
          mediaUrl: post.mediaUrl,
          userAvatarUrl: post.userAvatarUrl,
          likes: post.likes + (isLiked ? 1 : -1),
          comments: post.comments,
          isLiked: isLiked,
        );
      }
      return post;
    }).toList();

    await _saveFeed(updatedFeed);
  }
}
