import 'package:dartz/dartz.dart';
import 'package:paypulse/core/errors/failures.dart';
import 'package:paypulse/data/models/community_post_model.dart';
import 'package:paypulse/data/remote/datasources/community_datasource.dart';
import 'package:paypulse/domain/entities/community_post_entity.dart';
import 'package:paypulse/domain/repositories/community_repository.dart';

class CommunityRepositoryImpl implements CommunityRepository {
  final CommunityDataSource _dataSource;

  CommunityRepositoryImpl({required CommunityDataSource dataSource})
      : _dataSource = dataSource;

  @override
  Future<Either<Failure, List<CommunityPost>>> getPosts({
    int limit = 20,
    dynamic lastDoc,
  }) async {
    try {
      final posts = await _dataSource.getPosts(limit: limit, lastDoc: lastDoc);
      return Right(posts);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> createPost(CommunityPost post) async {
    try {
      final model = CommunityPostModel.fromEntity(post);
      await _dataSource.createPost(model);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deletePost(String postId) async {
    try {
      await _dataSource.deletePost(postId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> likePost(String postId, String userId) async {
    try {
      await _dataSource.likePost(postId, userId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> unlikePost(String postId, String userId) async {
    try {
      await _dataSource.unlikePost(postId, userId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
