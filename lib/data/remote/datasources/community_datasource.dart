import 'package:paypulse/data/models/community_post_model.dart';

abstract class CommunityDataSource {
  Future<List<CommunityPostModel>> getPosts({
    int limit = 20,
    dynamic lastDoc,
  });

  Future<void> createPost(CommunityPostModel post);

  Future<void> deletePost(String postId);

  Future<void> likePost(String postId, String userId);

  Future<void> unlikePost(String postId, String userId);
}
