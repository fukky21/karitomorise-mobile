import 'dart:async';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/index.dart';
import '../utils/index.dart';

class FirebaseUserRepository {
  FirebaseUserRepository({
    @required this.firebaseAuth,
    @required this.firebaseFirestore,
  });

  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firebaseFirestore;

  static const _collectionName = 'users';
  static const _documentVersionFieldName = 'document_version';
  static const _displayNameFieldName = 'display_name';
  static const _biographyFieldName = 'biography';
  static const _avatarIdFieldName = 'avatar_id';
  static const _mainWeaponIdFieldName = 'main_weapon_id';
  static const _firstPlayedSeriesIdFieldName = 'first_played_series_id';
  static const _followingFieldName = 'following';
  static const _followersFieldName = 'followers';
  static const _favoritesFieldName = 'favorites';
  static const _createdAtFieldName = 'created_at';
  static const _updatedAtFieldName = 'updated_at';

  Future<void> createUser(String displayName) async {
    final currentUser = firebaseAuth.currentUser;
    final avatarId = 1 + math.Random().nextInt(UserAvatar.values.length);
    final now = DateTime.now();

    await firebaseFirestore
        .collection(_collectionName)
        .doc(currentUser.uid)
        .set(
      <String, dynamic>{
        _documentVersionFieldName: 1,
        _displayNameFieldName: displayName,
        _biographyFieldName: 'よろしくお願いします！',
        _avatarIdFieldName: avatarId,
        _mainWeaponIdFieldName: null,
        _firstPlayedSeriesIdFieldName: null,
        _followingFieldName: <String>[],
        _followersFieldName: <String>[],
        _favoritesFieldName: <String>[],
        _createdAtFieldName: now,
        _updatedAtFieldName: now,
      },
    );
  }

  Future<AppUser> getUser(String uid) async {
    final doc =
        await firebaseFirestore.collection(_collectionName).doc(uid).get();
    if (doc.data() == null) {
      return null; // ユーザーがすでに削除されている場合
    }
    return _getUserFromDocument(doc);
  }

  Future<void> updateUser(AppUser user) async {
    final currentUser = firebaseAuth.currentUser;
    final now = DateTime.now();
    await firebaseFirestore
        .collection(_collectionName)
        .doc(currentUser.uid)
        .update(
      <String, dynamic>{
        _displayNameFieldName: user.displayName,
        _biographyFieldName: user.biography,
        _avatarIdFieldName: user.avatar?.id,
        _mainWeaponIdFieldName: user.mainWeapon?.id,
        _firstPlayedSeriesIdFieldName: user.firstPlayedSeries?.id,
        _updatedAtFieldName: now,
      },
    );
  }

  Future<void> followUser(String uid) async {
    final currentUser = firebaseAuth.currentUser;
    await firebaseFirestore.runTransaction((transaction) async {
      transaction
        ..update(
          firebaseFirestore.collection(_collectionName).doc(currentUser.uid),
          <String, dynamic>{
            _followingFieldName: FieldValue.arrayUnion(<String>[uid]),
          },
        )
        ..update(
          firebaseFirestore.collection(_collectionName).doc(uid),
          <String, dynamic>{
            _followersFieldName:
                FieldValue.arrayUnion(<String>[currentUser.uid]),
          },
        );
    });
  }

  Future<void> unFollowUser(String uid) async {
    final currentUser = firebaseAuth.currentUser;
    await firebaseFirestore.runTransaction((transaction) async {
      transaction
        ..update(
          firebaseFirestore.collection(_collectionName).doc(currentUser.uid),
          <String, dynamic>{
            _followingFieldName: FieldValue.arrayRemove(<String>[uid]),
          },
        )
        ..update(
          firebaseFirestore.collection(_collectionName).doc(uid),
          <String, dynamic>{
            _followersFieldName:
                FieldValue.arrayRemove(<String>[currentUser.uid]),
          },
        );
    });
  }

  Future<List<String>> getFollowing(String uid) async {
    final doc =
        await firebaseFirestore.collection(_collectionName).doc(uid).get();
    if (doc.data() == null) {
      return null; // ユーザーがすでに削除されている場合
    }
    return _getFollowingFromDocument(doc);
  }

  Future<List<String>> getFollowers(String uid) async {
    final doc =
        await firebaseFirestore.collection(_collectionName).doc(uid).get();
    if (doc.data() == null) {
      return null; // ユーザーがすでに削除されている場合
    }
    return _getFollowersFromDocument(doc);
  }

  Future<void> addToFavorites(String eventId) async {
    final currentUser = firebaseAuth.currentUser;
    await firebaseFirestore
        .collection(_collectionName)
        .doc(currentUser.uid)
        .update(
      <String, dynamic>{
        _favoritesFieldName: FieldValue.arrayUnion(<String>[eventId]),
      },
    );
  }

  Future<void> removeFromFavorites(String eventId) async {
    final currentUser = firebaseAuth.currentUser;
    await firebaseFirestore
        .collection(_collectionName)
        .doc(currentUser.uid)
        .update(
      <String, dynamic>{
        _favoritesFieldName: FieldValue.arrayRemove(<String>[eventId]),
      },
    );
  }

  Future<List<String>> getFavorites(String uid) async {
    final doc =
        await firebaseFirestore.collection(_collectionName).doc(uid).get();
    if (doc.data() == null) {
      return null; // ユーザーがすでに削除されている場合
    }
    return _getFavoritesFromDocument(doc);
  }

  AppUser _getUserFromDocument(DocumentSnapshot doc) {
    final data = doc.data();

    final user = AppUser(
      id: doc.id,
      displayName: data[_displayNameFieldName] as String,
      biography: data[_biographyFieldName] as String,
      avatar: getUserAvatar(id: data[_avatarIdFieldName] as int),
      mainWeapon: Weapons.get(id: data[_mainWeaponIdFieldName] as int),
      firstPlayedSeries: getMonsterHunterSeries(
        id: data[_firstPlayedSeriesIdFieldName] as int,
      ),
      createdEventCount: 0, // TODO(Fukky21): createdEventCount修正
      followingCount: (data[_followingFieldName] as List<dynamic>).length,
      followerCount: (data[_followersFieldName] as List<dynamic>).length,
      createdAt: (data[_createdAtFieldName] as Timestamp)?.toDate(),
      updatedAt: (data[_updatedAtFieldName] as Timestamp)?.toDate(),
    );

    return user;
  }

  List<String> _getFollowingFromDocument(DocumentSnapshot doc) {
    final data = doc.data();
    final following = <String>[];
    for (final userId in data[_followingFieldName] as List<dynamic>) {
      following.add(userId as String);
    }
    return following;
  }

  List<String> _getFollowersFromDocument(DocumentSnapshot doc) {
    final data = doc.data();
    final followers = <String>[];
    for (final userId in data[_followersFieldName] as List<dynamic>) {
      followers.add(userId as String);
    }
    return followers;
  }

  List<String> _getFavoritesFromDocument(DocumentSnapshot doc) {
    final data = doc.data();
    final favorites = <String>[];
    for (final eventId in data[_favoritesFieldName] as List<dynamic>) {
      favorites.add(eventId as String);
    }
    return favorites;
  }
}
