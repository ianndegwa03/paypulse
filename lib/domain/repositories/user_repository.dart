import 'package:dartz/dartz.dart';
import 'package:paypulse/core/errors/failures.dart';
import 'package:paypulse/domain/entities/user_entity.dart';

abstract class UserRepository {
  Future<Either<Failure, List<UserEntity>>> findUsersByPhoneNumbers(
      List<String> phoneNumbers);

  Future<Either<Failure, List<UserEntity>>> getLatestUsers({int limit = 50});

  Future<Either<Failure, void>> banUser(String userId, bool ban);
}
