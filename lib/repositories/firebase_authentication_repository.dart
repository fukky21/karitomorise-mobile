import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/index.dart';

class FirebaseAuthenticationRepository {
  FirebaseAuthenticationRepository({@required this.firebaseAuth});

  final FirebaseAuth firebaseAuth;

  CurrentUser getCurrentUser() {
    final currentUser = firebaseAuth.currentUser;
    if (currentUser != null) {
      return CurrentUser(
        uid: currentUser.uid,
        email: currentUser.email,
        isAnonymous: currentUser.isAnonymous,
        createdAt: currentUser.metadata.creationTime,
        updatedAt: currentUser.metadata.lastSignInTime,
      );
    }
    return null;
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signInAnonymously() async {
    await firebaseAuth.signInAnonymously();
  }

  Future<void> signOut() async {
    await firebaseAuth.signOut();
  }

  Future<void> signUpWithEmailAndPassword(String email, String password) async {
    final credential = await firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await credential.user.sendEmailVerification(); // 確認メールを送信する
  }

  Future<void> deleteCurrentUser() async {
    await firebaseAuth.currentUser.delete();
  }
}
