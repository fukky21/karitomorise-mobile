import 'dart:async';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/app_user.dart';

class FirebaseUserRepository {
  final _firebaseAuth = FirebaseAuth.instance;
  final _firebaseFirestore = FirebaseFirestore.instance;

  /// FirebaseAuthenticationRepositoryでサインアップしてから呼ぶ
  Future<void> createUser({@required String name}) async {
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null || currentUser.isAnonymous) {
      throw Exception('currentUser is null OR anonymous');
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
        'document_version': 1,
        'name': name,
        'avatar_id': avatarId,
        'created_at': now,
        'updated_at': now,
      },
    );
  }

  Future<AppUser> getUser({@required String id}) async {
    final snapshot = await _firebaseFirestore.collection('users').doc(id).get();

    if (!snapshot.exists) {
      // ドキュメントが存在しない場合
      return null;
    }

    final data = snapshot.data();

    return AppUser(
      id: snapshot.id,
      name: data['name'] as String,
      avatar: getAppUserAvatar(id: data['avatar_id'] as int),
    );
  }

  Future<void> updateUser({
    @required String name,
    @required AppUserAvatar avatar,
  }) async {
    final currentUser = _firebaseAuth.currentUser;
    final now = DateTime.now();

    if (currentUser == null || currentUser.isAnonymous) {
      // ここには来ないはず
      throw Exception('CurrentUser is null OR anonymous');
    }

    await _firebaseFirestore.collection('users').doc(currentUser.uid).update(
      <String, dynamic>{
        'name': name,
        'avatar_id': avatar?.id,
        'updated_at': now,
      },
    );
  }
}
