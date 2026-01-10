import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:paypulse/core/errors/failures.dart';
import 'package:paypulse/domain/entities/shared_space_entity.dart';
import 'package:paypulse/domain/repositories/shared_space_repository.dart';

class SharedSpaceRepositoryImpl implements SharedSpaceRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  SharedSpaceRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  @override
  Future<Either<Failure, void>> createSpace(
    String title,
    double totalAmount,
    List<String> memberIds,
  ) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return const Left(ServerFailure(message: 'User not authenticated'));
      }

      await _firestore.collection('shared_spaces').add({
        'title': title,
        'totalAmount': totalAmount,
        'paidAmount': 0.0, // Initial paid is 0
        'memberIds': memberIds,
        'createdBy': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'isSettled': false,
      });

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to create shared space: $e'));
    }
  }

  @override
  Stream<List<SharedSpaceEntity>> getMySpaces() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('shared_spaces')
        .where('memberIds', arrayContains: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return SharedSpaceEntity(
          id: doc.id,
          title: data['title'] ?? '',
          createdBy: data['createdBy'] ?? '',
          totalAmount: (data['totalAmount'] ?? 0).toDouble(),
          paidAmount: (data['paidAmount'] ?? 0).toDouble(),
          memberIds: List<String>.from(data['memberIds'] ?? []),
          createdAt:
              (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          isSettled: data['isSettled'] ?? false,
        );
      }).toList();
    });
  }

  @override
  Future<Either<Failure, void>> settleSpace(String spaceId) async {
    try {
      await _firestore.collection('shared_spaces').doc(spaceId).update({
        'isSettled': true,
        'paidAmount': FieldValue.increment(0), // Logic might vary
        // For now, settling just marks it complete
      });
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to settle space: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteSpace(String spaceId) async {
    try {
      await _firestore.collection('shared_spaces').doc(spaceId).delete();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to delete space: $e'));
    }
  }
}
