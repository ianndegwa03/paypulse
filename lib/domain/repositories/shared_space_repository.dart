import 'package:dartz/dartz.dart';
import 'package:paypulse/core/errors/failures.dart';
import 'package:paypulse/domain/entities/shared_space_entity.dart';

abstract class SharedSpaceRepository {
  Future<Either<Failure, void>> createSpace(
    String title,
    double totalAmount,
    List<String> memberIds,
  );

  Stream<List<SharedSpaceEntity>> getMySpaces();

  Future<Either<Failure, void>> settleSpace(String spaceId);

  Future<Either<Failure, void>> deleteSpace(String spaceId);
}
