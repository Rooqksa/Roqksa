import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Firestore-backed profile visit tracking.
class ProfileVisitService {
  ProfileVisitService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  /// Call when the signed-in user opens another member's public profile.
  /// A stable visitor document prevents duplicate rows; each visit refreshes
  /// lastVisitedAt instead of creating unlimited records.
  Future<void> recordVisit(String ownerUid) async {
    final visitor = _auth.currentUser;
    if (visitor == null || ownerUid.isEmpty || visitor.uid == ownerUid) return;

    final ref = _firestore
        .collection('profileVisits')
        .doc(ownerUid)
        .collection('visitors')
        .doc(visitor.uid);

    await ref.set({
      'ownerId': ownerUid,
      'visitorId': visitor.uid,
      'lastVisitedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Live visitor list for the currently signed-in profile owner.
  Stream<QuerySnapshot<Map<String, dynamic>>> watchMyVisitors() {
    final owner = _auth.currentUser;
    if (owner == null) return const Stream.empty();

    return _firestore
        .collection('profileVisits')
        .doc(owner.uid)
        .collection('visitors')
        .orderBy('lastVisitedAt', descending: true)
        .snapshots();
  }
}
