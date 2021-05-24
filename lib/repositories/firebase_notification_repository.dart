import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseNotificationRepository {
  final _firebaseAuth = FirebaseAuth.instance;
  final _firebaseFirestore = FirebaseFirestore.instance;

  Stream<List<int>> getPostNumberStream() {
    final currentUser = _firebaseAuth.currentUser;

    if (currentUser != null && !currentUser.isAnonymous) {
      return _firebaseFirestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('notifications')
          .orderBy('createdAt', descending: true)
          .limit(10)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          final postNumber = doc.data()['postNumber'] as int;
          return postNumber;
        }).toList();
      });
    }
    return null;
  }
}
