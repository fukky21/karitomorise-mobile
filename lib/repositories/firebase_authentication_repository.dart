import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/index.dart';

class FirebaseAuthenticationRepository {
  FirebaseAuthenticationRepository({@required FirebaseAuth firebaseAuth}) {
    _firebaseAuth = firebaseAuth;
  }

  FirebaseAuth _firebaseAuth;

  CurrentUser getCurrentUser() {
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser != null) {
      return CurrentUser(
        uid: currentUser.uid,
        email: currentUser.email,
        createdAt: currentUser.metadata.creationTime,
        updatedAt: currentUser.metadata.lastSignInTime,
      );
    }
    return null;
  }

  Stream<User> getAuthStateChanges() {
    return _firebaseAuth.authStateChanges();
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
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await credential.user.sendEmailVerification(); // 確認メールを送信する
    await _firebaseAuth.signOut(); // ユーザー作成後にサインイン状態にしない
  }

  Future<void> deleteCurrentUser() async {
    await _firebaseAuth.currentUser.delete();
  }
}
