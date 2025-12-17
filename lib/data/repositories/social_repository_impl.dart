import 'package:dartz/dartz.dart';
import 'package:paypulse/core/errors/failures.dart';
import 'package:paypulse/data/remote/datasources/social_datasource.dart';
import 'package:paypulse/domain/entities/social_post_entity.dart';
import 'package:paypulse/domain/repositories/social_repository.dart';

class SocialRepositoryImpl implements SocialRepository {
  final SocialDataSource dataSource;

  SocialRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, List<SocialPostEntity>>> getFeed() async {
    try {
      final feed = await dataSource.getFeed();
      return Right(feed);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to fetch social feed: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> createPost(String content) async {
    try {
      await dataSource.createPost(content);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to create post: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> likePost(String postId) async {
    try {
      await dataSource.likePost(postId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to like post: $e'));
    }
  }
}
