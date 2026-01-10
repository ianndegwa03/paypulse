import 'package:dartz/dartz.dart';
import 'package:paypulse/core/errors/failures.dart';
import 'package:paypulse/domain/entities/community_post_entity.dart';

abstract class CommunityRepository {
  Future<Either<Failure, List<CommunityPost>>> getPosts({
    int limit = 20,
    dynamic lastDoc,
  });

  Future<Either<Failure, void>> createPost(CommunityPost post);

  Future<Either<Failure, void>> deletePost(String postId);

  Future<Either<Failure, void>> likePost(String postId, String userId);

  Future<Either<Failure, void>> unlikePost(String postId, String userId);
}
