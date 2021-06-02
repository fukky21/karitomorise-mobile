import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/current_user.dart';

class FirebaseAuthenticationRepository {
  final _firebaseAuth = FirebaseAuth.instance;

  CurrentUser getCurrentUser() {
    final currentUser = _firebaseAuth.currentUser;
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

  Future<void> signInWithEmailAndPassword({
    @required String email,
    @required String password,
  }) async {
    await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signInAnonymously() async {
    await _firebaseAuth.signInAnonymously();
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<void> signUpWithEmailAndPassword({
    @required String email,
    @required String password,
  }) async {
    await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> sendEmailVerification() async {
    final currentUser = _firebaseAuth.currentUser;
    await currentUser.sendEmailVerification();
  }

  Future<void> updateEmail({
    @required String newEmail,
    @required String password,
  }) async {
    final currentUser = _firebaseAuth.currentUser;
    final currentEmail = currentUser.email;

    // 一度サインインし直す
    await signInWithEmailAndPassword(email: currentEmail, password: password);

    await currentUser.updateEmail(newEmail);
  }

  Future<void> updatePassword({
    @required String currentPassword,
    @required String newPassword,
  }) async {
    final currentUser = _firebaseAuth.currentUser;

    // 一度サインインし直す
    await signInWithEmailAndPassword(
      email: currentUser.email,
      password: currentPassword,
    );

    await currentUser.updatePassword(newPassword);
  }

  Future<void> sendPasswordResetEmail({@required String email}) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<void> deleteCurrentUser() async {
    await _firebaseAuth.currentUser.delete();
  }
}
