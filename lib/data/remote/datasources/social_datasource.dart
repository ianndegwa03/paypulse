import 'package:paypulse/data/models/social_post_model.dart';
import 'package:paypulse/domain/entities/social_post_entity.dart';
import 'package:paypulse/core/services/local_storage/storage_service.dart';

abstract class SocialDataSource {
  Future<List<SocialPostModel>> getFeed();
  Future<void> createPost({
    required String content,
    String? type,
    double? totalAmount,
    double? collectedAmount,
    String? transactionCategory,
    String? linkedId,
    String? title,
    List<String>? pollOptions,
    DateTime? deadline,
  });
  Future<void> likePost(String postId);
}

class SocialDataSourceImpl implements SocialDataSource {
  final StorageService storageService;
  static const String _feedKey = 'social_feed_data';

  SocialDataSourceImpl(this.storageService);

  @override
  Future<List<SocialPostModel>> getFeed() async {
    final List<dynamic>? storedList = await storageService.getList(_feedKey);
    if (storedList != null && storedList.isNotEmpty) {
      return storedList
          .map((e) => SocialPostModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    // No mock seed data as per user request.
    // Return empty list if no user-generated posts exist yet.
    return [];
  }

  Future<void> _saveFeed(List<SocialPostModel> feed) async {
    final List<Map<String, dynamic>> jsonList =
        feed.map((e) => e.toJson()).toList();
    await storageService.saveList(_feedKey, jsonList);
  }

  @override
  Future<void> createPost({
    required String content,
    String? type,
    double? totalAmount,
    double? collectedAmount,
    String? transactionCategory,
    String? linkedId,
    String? title,
    List<String>? pollOptions,
    DateTime? deadline,
  }) async {
    final currentFeed = await getFeed();
    final newPost = SocialPostModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: 'current_user',
      userName: 'You',
      content: content,
      userAvatarUrl: 'https://i.pravatar.cc/150?u=current_user',
      timestamp: DateTime.now(),
      type: type != null
          ? PostType.values
              .firstWhere((e) => e.name == type, orElse: () => PostType.regular)
          : PostType.regular,
      totalAmount: totalAmount,
      collectedAmount: collectedAmount,
      title: title,
    );
    await _saveFeed([newPost, ...currentFeed]);
  }

  @override
  Future<void> likePost(String postId) async {
    final currentFeed = await getFeed();
    final updatedFeed = currentFeed.map((post) {
      if (post.id == postId) {
        final isLiked = !post.isLiked;
        return post.copyWith(
            likes: post.likes + (isLiked ? 1 : -1), isLiked: isLiked);
      }
      return post;
    }).toList();
    await _saveFeed(updatedFeed);
  }
}
