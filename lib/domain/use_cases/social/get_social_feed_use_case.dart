import 'package:dartz/dartz.dart';
import 'package:paypulse/core/errors/failures.dart';
import 'package:paypulse/domain/entities/social_post_entity.dart';
import 'package:paypulse/domain/repositories/social_repository.dart';

class GetSocialFeedUseCase {
  final SocialRepository repository;

  GetSocialFeedUseCase(this.repository);

  Future<Either<Failure, List<SocialPostEntity>>> call() {
    return repository.getFeed();
  }
}
