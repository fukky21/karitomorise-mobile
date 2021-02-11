import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

import '../models/index.dart';

class FirebaseAuthenticationRepository {
  final _firebaseAuth = FirebaseAuth.instance;

  CurrentUser getCurrentUser() {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      return CurrentUser(
        uid: user.uid,
        email: user.email,
        createdAt: user.metadata.creationTime,
        updatedAt: user.metadata.lastSignInTime,
      );
    }
    return null;
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<void> signUpWithEmailAndPassword(String email, String password) async {
    final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await userCredential.user.sendEmailVerification(); // 確認メールを送信する
    await _firebaseAuth.signOut(); // ユーザー作成後にサインイン状態にしない
  }

  Future<void> deleteCurrentUser() async {
    await _firebaseAuth.currentUser.delete();
  }
}
