import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paypulse/domain/entities/vouch_entity.dart';

abstract class VouchRepository {
  Future<void> vouchForUser(String voucheeId, String? comment);
  Stream<List<Vouch>> getVouchesForUser(String userId);
}

class VouchRepositoryImpl implements VouchRepository {
  final FirebaseFirestore _firestore;
  final String _currentUserId;

  VouchRepositoryImpl(this._firestore, this._currentUserId);

  @override
  Future<void> vouchForUser(String voucheeId, String? comment) async {
    final vouchRef = _firestore.collection('vouches').doc();
    await vouchRef.set({
      'id': vouchRef.id,
      'voucherId': _currentUserId,
      'voucheeId': voucheeId,
      'date': FieldValue.serverTimestamp(),
      'comment': comment,
    });
  }

  @override
  Stream<List<Vouch>> getVouchesForUser(String userId) {
    return _firestore
        .collection('vouches')
        .where('voucheeId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return Vouch(
                id: doc.id,
                voucherId: data['voucherId'] ?? '',
                voucheeId: data['voucheeId'] ?? '',
                date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
                comment: data['comment'],
              );
            }).toList());
  }
}
