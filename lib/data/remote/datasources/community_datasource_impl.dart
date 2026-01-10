import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paypulse/data/models/community_post_model.dart';
import 'package:paypulse/data/remote/datasources/community_datasource.dart';

class CommunityDataSourceImpl implements CommunityDataSource {
  final FirebaseFirestore _firestore;

  CommunityDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<CommunityPostModel>> getPosts({
    int limit = 20,
    dynamic lastDoc,
  }) async {
    Query query = _firestore
        .collection('community_posts')
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (lastDoc != null && lastDoc is DocumentSnapshot) {
      query = query.startAfterDocument(lastDoc);
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => CommunityPostModel.fromSnapshot(doc))
        .toList();
  }

  @override
  Future<void> createPost(CommunityPostModel post) async {
    await _firestore.collection('community_posts').add(post.toDocument());
  }

  @override
  Future<void> deletePost(String postId) async {
    await _firestore.collection('community_posts').doc(postId).delete();
  }

  @override
  Future<void> likePost(String postId, String userId) async {
    await _firestore.collection('community_posts').doc(postId).update({
      'likes': FieldValue.increment(1),
      'likedBy': FieldValue.arrayUnion([userId]),
    });
  }

  @override
  Future<void> unlikePost(String postId, String userId) async {
    await _firestore.collection('community_posts').doc(postId).update({
      'likes': FieldValue.increment(-1),
      'likedBy': FieldValue.arrayRemove([userId]),
    });
  }
}
