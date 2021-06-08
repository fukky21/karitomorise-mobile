import 'dart:async';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/app_user.dart';

class FirebaseUserRepository {
  final _firebaseAuth = FirebaseAuth.instance;
  final _firebaseFirestore = FirebaseFirestore.instance;

  // FirebaseAuthenticationRepositoryでサインアップしてから実行する
  Future<void> createUser({@required String name}) async {
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null || currentUser.isAnonymous) {
      throw Exception('currentUser is null or anonymous');
    }

    // ランダムにアバターを選ぶ
    var avatarId = 1 + math.Random().nextInt(AppUserAvatar.values.length);

    // アバターにUnknownが選ばれないようにする
    if (getAppUserAvatar(id: avatarId) == AppUserAvatar.unknown) {
      avatarId = AppUserAvatar.agnaktor.id;
    }

    final now = DateTime.now();

    await _firebaseFirestore.collection('users').doc(currentUser.uid).set(
      <String, dynamic>{
        'documentVersion': 1,
        'name': name,
        'avatarId': avatarId,
        'fcmTokens': <String>[],
        'isAvailable': true,
        'createdAt': now,
        'updatedAt': now,
        'deletedAt': null,
      },
    );
  }

  Future<bool> isAvailable({@required String id}) async {
    final snapshot = await _firebaseFirestore.collection('users').doc(id).get();

    if (snapshot.exists) {
      return snapshot.data()['isAvailable'] as bool;
    } else {
      debugPrint('User document is not found.');
      return null;
    }
  }

  Future<AppUser> getUser({@required String id}) async {
    final snapshot = await _firebaseFirestore.collection('users').doc(id).get();

    if (snapshot.exists) {
      final data = snapshot.data();

      if (data['deletedAt'] != null) {
        // 削除済ユーザーの場合
        return AppUser(
          id: snapshot.id,
          name: '(このユーザーは削除されました)',
          avatar: null,
        );
      } else {
        return AppUser(
          id: snapshot.id,
          name: data['name'] as String,
          avatar: getAppUserAvatar(id: data['avatarId'] as int),
        );
      }
    }
    return null;
  }

  Future<void> updateUser({
    @required String name,
    @required AppUserAvatar avatar,
  }) async {
    final currentUser = _firebaseAuth.currentUser;
    final now = DateTime.now();

    if (currentUser == null || currentUser.isAnonymous) {
      throw Exception('CurrentUser is null or anonymous');
    }

    await _firebaseFirestore.collection('users').doc(currentUser.uid).update(
      <String, dynamic>{
        'name': name,
        'avatarId': avatar?.id,
        'updatedAt': now,
      },
    );
  }

  Future<void> addToken({@required String token}) async {
    final currentUser = _firebaseAuth.currentUser;
    if (token != null && currentUser != null && !currentUser.isAnonymous) {
      final docRef =
          _firebaseFirestore.collection('users').doc(currentUser.uid);
      await _firebaseFirestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (snapshot.exists) {
          transaction.update(
            docRef,
            <String, dynamic>{
              'fcmTokens': FieldValue.arrayUnion(<String>[token]),
            },
          );
        }
      });
    }
  }

  Future<void> removeToken({@required String token}) async {
    final currentUser = _firebaseAuth.currentUser;
    if (token != null && currentUser != null && !currentUser.isAnonymous) {
      final docRef =
          _firebaseFirestore.collection('users').doc(currentUser.uid);
      await _firebaseFirestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (snapshot.exists) {
          transaction.update(
            docRef,
            <String, dynamic>{
              'fcmTokens': FieldValue.arrayRemove(<String>[token]),
            },
          );
        }
      });
    }
  }

  Future<void> deleteUser() async {
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null || currentUser.isAnonymous) {
      throw Exception('currentUser is null or anonymous');
    }
    await _firebaseFirestore.collection('users').doc(currentUser.uid).update({
      'deletedAt': DateTime.now(),
    });
  }
}
