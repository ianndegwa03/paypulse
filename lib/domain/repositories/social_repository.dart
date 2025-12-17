import 'package:dartz/dartz.dart';
import 'package:paypulse/core/errors/failures.dart';
import 'package:paypulse/domain/entities/social_post_entity.dart';

abstract class SocialRepository {
  Future<Either<Failure, List<SocialPostEntity>>> getFeed();
  Future<Either<Failure, void>> createPost(String content);
  Future<Either<Failure, void>> likePost(String postId);
}
