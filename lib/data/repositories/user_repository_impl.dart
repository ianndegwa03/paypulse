import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:paypulse/core/errors/failures.dart';
import 'package:paypulse/data/models/shared/user_model.dart';
import 'package:paypulse/data/remote/mappers/user_mapper.dart';
import 'package:paypulse/domain/entities/user_entity.dart';
import 'package:paypulse/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final FirebaseFirestore _firestore;
  final UserMapper _userMapper;

  UserRepositoryImpl(this._firestore, this._userMapper);

  @override
  Future<Either<Failure, List<UserEntity>>> findUsersByPhoneNumbers(
      List<String> phoneNumbers) async {
    try {
      if (phoneNumbers.isEmpty) return const Right([]);

      // Firestore 'whereIn' is limited to 10 values
      final List<UserEntity> allFoundUsers = [];

      // Clean phone numbers first (ensure non-empty)
      final cleanNumbers =
          phoneNumbers.where((p) => p.isNotEmpty).toSet().toList();

      // Process in chunks of 10
      for (var i = 0; i < cleanNumbers.length; i += 10) {
        final end =
            (i + 10 < cleanNumbers.length) ? i + 10 : cleanNumbers.length;
        final chunk = cleanNumbers.sublist(i, end);

        final querySnapshot = await _firestore
            .collection('users')
            .where('phoneNumber', whereIn: chunk)
            .get();

        final users = querySnapshot.docs.map((doc) {
          final data = doc.data();
          // Ensure ID is present
          data['id'] = doc.id;
          return _userMapper.modelToEntity(UserModel.fromJson(data));
        }).toList();

        allFoundUsers.addAll(users);
      }

      return Right(allFoundUsers);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to search users: $e'));
    }
  }

  @override
  Future<Either<Failure, List<UserEntity>>> getLatestUsers(
      {int limit = 50}) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      final users = querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return _userMapper.modelToEntity(UserModel.fromJson(data));
      }).toList();

      return Right(users);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to fetch users: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> banUser(String userId, bool ban) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'is_banned': ban,
        'isBanned': ban,
      });
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to ban user: $e'));
    }
  }
}
