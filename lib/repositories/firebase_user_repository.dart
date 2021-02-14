import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/index.dart';

class FirebaseUserRepository {
  static const collectionName = 'users';
  static const subCollectionName = '_users';
  static const documentVersionFieldName = 'document_version';
  static const displayNameFieldName = 'display_name';
  static const biographyFieldName = 'biography';
  static const avatarTypeFieldName = 'avatar_type';
  static const mainWeaponTypeFieldName = 'main_weapon_type';
  static const firstPlayedSeriesTypeFieldName = 'first_played_series_type';
  static const createdEventsFieldName = 'created_events';
  static const participatedEventsFieldName = 'participated_events';
  static const likedEventsFieldName = 'liked_events';
  static const followingFieldName = 'following';
  static const followersFieldName = 'followers';
  static const createdAtFieldName = 'created_at';
  static const updatedAtFieldName = 'updated_at';

  final _firebaseAuth = FirebaseAuth.instance;
  final _firebaseFirestore = FirebaseFirestore.instance;

  Future<AppUser> getUser(String uid) async {
    final doc =
        await _firebaseFirestore.collection(collectionName).doc(uid).get();
    final subDoc =
        await _firebaseFirestore.collection(subCollectionName).doc(uid).get();
    if (doc.data() == null) {
      return null; // ユーザーがすでに削除されている場合
    }
    return getUserFromDocuments(doc, subDoc);
  }

  Future<void> updateUser(AppUser user) async {
    final currentUser = _firebaseAuth.currentUser;
    final now = DateTime.now();
    await _firebaseFirestore
        .collection(collectionName)
        .doc(currentUser.uid)
        .update(
      <String, dynamic>{
        displayNameFieldName: user.displayName,
        avatarTypeFieldName: user.avatarType,
        biographyFieldName: user.biography,
        mainWeaponTypeFieldName: user.mainWeaponType,
        firstPlayedSeriesTypeFieldName: user.firstPlayedSeriesType,
        updatedAtFieldName: now,
      },
    );
  }

  Future<List<String>> getLikes(String uid) async {
    final doc =
        await _firebaseFirestore.collection(collectionName).doc(uid).get();
    if (doc.data() == null) {
      return <String>[]; // ユーザーがすでに削除されている場合
    }
    return getLikesFromDocument(doc);
  }

  Future<void> addLike(String eventId) async {
    final currentUser = _firebaseAuth.currentUser;
    await _firebaseFirestore
        .collection(collectionName)
        .doc(currentUser.uid)
        .update(
      <String, dynamic>{
        likedEventsFieldName: FieldValue.arrayUnion(<String>[eventId]),
      },
    );
  }

  Future<void> removeLike(String eventId) async {
    final currentUser = _firebaseAuth.currentUser;
    await _firebaseFirestore
        .collection(collectionName)
        .doc(currentUser.uid)
        .update(
      <String, dynamic>{
        likedEventsFieldName: FieldValue.arrayRemove(<String>[eventId]),
      },
    );
  }

  Future<List<String>> getFollowing(String uid) async {
    final subDoc =
        await _firebaseFirestore.collection(subCollectionName).doc(uid).get();
    if (subDoc.data() == null) {
      return []; // ユーザーがすでに削除されている場合
    }
    return getFollowingFromDocument(subDoc);
  }

  Future<List<String>> getFollowers(String uid) async {
    final subDoc =
        await _firebaseFirestore.collection(subCollectionName).doc(uid).get();
    if (subDoc.data() == null) {
      return []; // ユーザーがすでに削除されている場合
    }
    return getFollowersFromDocument(subDoc);
  }

  Future<void> addFollow(String uid) async {
    final currentUser = _firebaseAuth.currentUser;
    await _firebaseFirestore.runTransaction((transaction) async {
      transaction
        ..update(
          _firebaseFirestore.collection(subCollectionName).doc(currentUser.uid),
          <String, dynamic>{
            followingFieldName: FieldValue.arrayUnion(<String>[uid]),
          },
        )
        ..update(
          _firebaseFirestore.collection('_users').doc(uid),
          <String, dynamic>{
            followersFieldName:
                FieldValue.arrayUnion(<String>[currentUser.uid]),
          },
        );
    });
  }

  Future<void> removeFollow(String uid) async {
    final currentUser = _firebaseAuth.currentUser;
    await _firebaseFirestore.runTransaction((transaction) async {
      transaction
        ..update(
          _firebaseFirestore.collection(subCollectionName).doc(currentUser.uid),
          <String, dynamic>{
            followingFieldName: FieldValue.arrayRemove(<String>[uid]),
          },
        )
        ..update(
          _firebaseFirestore.collection(subCollectionName).doc(uid),
          <String, dynamic>{
            followersFieldName:
                FieldValue.arrayRemove(<String>[currentUser.uid]),
          },
        );
    });
  }

  Stream<DocumentSnapshot> getDocumentSnapshots(String uid) {
    return _firebaseFirestore.collection(collectionName).doc(uid).snapshots();
  }

  Stream<DocumentSnapshot> getSubDocumentSnapshots(String uid) {
    return _firebaseFirestore
        .collection(subCollectionName)
        .doc(uid)
        .snapshots();
  }

  AppUser getUserFromDocuments(DocumentSnapshot doc, DocumentSnapshot subDoc) {
    final data = doc.data();
    final subData = subDoc.data();

    return AppUser(
      id: doc.id,
      displayName: data[displayNameFieldName] as String,
      biography: data[biographyFieldName] as String,
      avatarType: data[avatarTypeFieldName] as int,
      mainWeaponType: data[mainWeaponTypeFieldName] as int,
      firstPlayedSeriesType: data[firstPlayedSeriesTypeFieldName] as int,
      createdEventCount: (data[createdEventsFieldName] as List<dynamic>).length,
      followingCount: (subData[followingFieldName] as List<dynamic>).length,
      followerCount: (subData[followersFieldName] as List<dynamic>).length,
      createdAt: (data[createdAtFieldName] as Timestamp)?.toDate(),
      updatedAt: (data[updatedAtFieldName] as Timestamp)?.toDate(),
    );
  }

  List<String> getLikesFromDocument(DocumentSnapshot doc) {
    final data = doc.data();
    final likedEvents = <String>[];
    for (final eventId in data[likedEventsFieldName] as List<dynamic>) {
      likedEvents.add(eventId as String);
    }
    return likedEvents;
  }

  List<String> getFollowingFromDocument(DocumentSnapshot subDoc) {
    final data = subDoc.data();
    final following = <String>[];
    for (final userId in data[followingFieldName] as List<dynamic>) {
      following.add(userId as String);
    }
    return following;
  }

  List<String> getFollowersFromDocument(DocumentSnapshot subDoc) {
    final data = subDoc.data();
    final followers = <String>[];
    for (final userId in data[followersFieldName] as List<dynamic>) {
      followers.add(userId as String);
    }
    return followers;
  }
}
