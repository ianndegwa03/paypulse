import 'package:dartz/dartz.dart';
import 'package:paypulse/core/errors/failures.dart';
import 'package:paypulse/domain/entities/social_post_entity.dart';

abstract class SocialRepository {
  Future<Either<Failure, List<SocialPostEntity>>> getFeed();
  Future<Either<Failure, void>> createPost({
    required String content,
    PostType type = PostType.regular,
    double? totalAmount,
    double? collectedAmount,
    String? transactionCategory,
    String? linkedId,
    String? title,
    List<String>? pollOptions,
    DateTime? deadline,
  });
  Future<Either<Failure, void>> likePost(String postId);
}
