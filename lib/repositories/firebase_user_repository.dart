import 'dart:async';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/index.dart';

class FirebaseUserRepository {
  FirebaseUserRepository({
    @required this.firebaseAuth,
    @required this.firebaseFirestore,
  });

  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firebaseFirestore;

  static const collectionName = 'users';
  static const documentVersionFieldName = 'document_version';
  static const nameFieldName = 'name';
  static const avatarIdFieldName = 'avatar_id';
  static const createdAtFieldName = 'created_at';
  static const updatedAtFieldName = 'updated_at';

  // FirebaseAuthenticationRepositoryの方でサインアップしてから実行すること
  Future<void> createUser({@required String name}) async {
    final currentUser = firebaseAuth.currentUser;
    if (currentUser == null || currentUser.isAnonymous) {
      throw Exception('currentUser is null OR currentUser is anonymous');
    }

    var avatarId = 1 + math.Random().nextInt(AppUserAvatar.values.length);

    // アイコンにUnknownが選ばれないようにする
    if (getAppUserAvatar(id: avatarId) == AppUserAvatar.unknown) {
      avatarId = AppUserAvatar.agnaktor.id;
    }

    final now = DateTime.now();

    await firebaseFirestore.collection(collectionName).doc(currentUser.uid).set(
      <String, dynamic>{
        documentVersionFieldName: 1,
        nameFieldName: name,
        avatarIdFieldName: avatarId,
        createdAtFieldName: now,
        updatedAtFieldName: now,
      },
    );
  }

  Future<AppUser> getUser({@required String id}) async {
    final doc =
        await firebaseFirestore.collection(collectionName).doc(id).get();
    final data = doc.data();

    if (data == null) {
      return null; // ユーザーがすでに削除されている場合
    }

    return AppUser(
      id: doc.id,
      name: data[nameFieldName] as String,
      avatar: getAppUserAvatar(id: data[avatarIdFieldName] as int),
    );
  }

  Future<void> updateUser({
    @required String name,
    @required AppUserAvatar avatar,
  }) async {
    final currentUser = firebaseAuth.currentUser;
    final now = DateTime.now();

    if (currentUser.isAnonymous) {
      // ここには来ないはず
      throw Exception('CurrentUser is anonymous');
    }

    await firebaseFirestore
        .collection(collectionName)
        .doc(currentUser.uid)
        .update(
      <String, dynamic>{
        nameFieldName: name,
        avatarIdFieldName: avatar?.id,
        updatedAtFieldName: now,
      },
    );
  }
}
