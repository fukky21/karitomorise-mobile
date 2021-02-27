import 'dart:async';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/index.dart';
import '../utils/index.dart';

class FirebaseUserRepository {
  FirebaseUserRepository({
    @required FirebaseAuth firebaseAuth,
    @required FirebaseFirestore firebaseFirestore,
  }) {
    _firebaseAuth = firebaseAuth;
    _firebaseFirestore = firebaseFirestore;
  }

  FirebaseAuth _firebaseAuth;
  FirebaseFirestore _firebaseFirestore;

  static const _collectionName = 'users';
  static const _documentVersionFieldName = 'document_version';
  static const _displayNameFieldName = 'display_name';
  static const _biographyFieldName = 'biography';
  static const _avatarTypeFieldName = 'avatar_type';
  static const _mainWeaponTypeFieldName = 'main_weapon_type';
  static const _firstPlayedSeriesFieldName = 'first_played_series';
  static const _followingFieldName = 'following';
  static const _followersFieldName = 'followers';
  static const _createdAtFieldName = 'created_at';
  static const _updatedAtFieldName = 'updated_at';

  Future<void> createUser(String displayName) async {
    final currentUser = _firebaseAuth.currentUser;
    final avatarType = math.Random().nextInt(AvatarType.values.length);
    final now = DateTime.now();

    await _firebaseFirestore
        .collection(_collectionName)
        .doc(currentUser.uid)
        .set(
      <String, dynamic>{
        _documentVersionFieldName: 1,
        _displayNameFieldName: displayName,
        _biographyFieldName: 'よろしくお願いします！',
        _avatarTypeFieldName: avatarType,
        _mainWeaponTypeFieldName: null,
        _firstPlayedSeriesFieldName: null,
        _followingFieldName: <String>[],
        _followersFieldName: <String>[],
        _createdAtFieldName: now,
        _updatedAtFieldName: now,
      },
    );
  }

  Future<AppUser> getUser(String uid) async {
    final doc =
        await _firebaseFirestore.collection(_collectionName).doc(uid).get();
    if (doc.data() == null) {
      return null; // ユーザーがすでに削除されている場合
    }
    return _getUserFromDocument(doc);
  }

  Future<void> updateUser(AppUser user) async {
    final currentUser = _firebaseAuth.currentUser;
    final now = DateTime.now();
    await _firebaseFirestore
        .collection(_collectionName)
        .doc(currentUser.uid)
        .update(
      <String, dynamic>{
        _displayNameFieldName: user.displayName,
        _biographyFieldName: user.biography,
        _avatarTypeFieldName: user.avatarType?.index,
        _mainWeaponTypeFieldName: user.mainWeapon?.type,
        _firstPlayedSeriesFieldName: user.firstPlayedSeries?.index,
        _updatedAtFieldName: now,
      },
    );
  }

  Future<void> followUser(String uid) async {
    final currentUser = _firebaseAuth.currentUser;
    await _firebaseFirestore.runTransaction((transaction) async {
      transaction
        ..update(
          _firebaseFirestore.collection(_collectionName).doc(currentUser.uid),
          <String, dynamic>{
            _followingFieldName: FieldValue.arrayUnion(<String>[uid]),
          },
        )
        ..update(
          _firebaseFirestore.collection(_collectionName).doc(uid),
          <String, dynamic>{
            _followersFieldName:
                FieldValue.arrayUnion(<String>[currentUser.uid]),
          },
        );
    });
  }

  Future<void> unFollowUser(String uid) async {
    final currentUser = _firebaseAuth.currentUser;
    await _firebaseFirestore.runTransaction((transaction) async {
      transaction
        ..update(
          _firebaseFirestore.collection(_collectionName).doc(currentUser.uid),
          <String, dynamic>{
            _followingFieldName: FieldValue.arrayRemove(<String>[uid]),
          },
        )
        ..update(
          _firebaseFirestore.collection(_collectionName).doc(uid),
          <String, dynamic>{
            _followersFieldName:
                FieldValue.arrayRemove(<String>[currentUser.uid]),
          },
        );
    });
  }

  AppUser _getUserFromDocument(DocumentSnapshot doc) {
    final data = doc.data();

    final user = AppUser(
      id: doc.id,
      displayName: data[_displayNameFieldName] as String,
      biography: data[_biographyFieldName] as String,
      mainWeapon: Weapons.get(type: data[_mainWeaponTypeFieldName] as int),
      createdEventCount: 0, // TODO(Fukky21): createdEventCount修正
      followingCount: (data[_followingFieldName] as List<dynamic>).length,
      followerCount: (data[_followersFieldName] as List<dynamic>).length,
      createdAt: (data[_createdAtFieldName] as Timestamp)?.toDate(),
      updatedAt: (data[_updatedAtFieldName] as Timestamp)?.toDate(),
    );

    final avatarTypeIndex = data[_avatarTypeFieldName] as int;
    if (avatarTypeIndex != null) {
      user.avatarType = AvatarType.values[avatarTypeIndex];
    }

    final monsterHunterSeriesIndex = data[_firstPlayedSeriesFieldName] as int;
    if (monsterHunterSeriesIndex != null) {
      user.firstPlayedSeries =
          MonsterHunterSeries.values[monsterHunterSeriesIndex];
    }

    final currentUser = _firebaseAuth.currentUser;
    if (currentUser != null) {
      if (user.id != currentUser.uid) {
        final followers = _getFollowersFromDocument(doc);
        if (followers.contains(currentUser.uid)) {
          user.isFollowed = true;
        } else {
          user.isFollowed = false;
        }
      }
    }

    return user;
  }

  List<String> _getFollowersFromDocument(DocumentSnapshot doc) {
    final data = doc.data();
    final followers = <String>[];
    for (final userId in data[_followersFieldName] as List<dynamic>) {
      followers.add(userId as String);
    }
    return followers;
  }
}
