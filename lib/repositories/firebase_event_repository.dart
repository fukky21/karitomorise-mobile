import 'dart:async';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/index.dart';
import '../widgets/components/index.dart';

class FirebaseEventRepository {
  FirebaseEventRepository({
    @required this.firebaseAuth,
    @required this.firebaseFirestore,
  });

  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firebaseFirestore;

  static const _collectionName = 'events';
  static const _documentVersionFieldName = 'document_version';
  static const _uidFieldName = 'uid';
  static const _descriptionFieldName = 'description';
  static const _typeIdFieldName = 'type_id';
  static const _questRankIdFieldName = 'quest_rank_id';
  static const _targetLevelIdFieldName = 'target_level_id';
  static const _playTimeIdFieldName = 'play_time_id';
  static const _isClosedFieldName = 'is_closed';
  static const _commentCountFieldName = 'comment_count';
  static const _createdAtFieldName = 'created_at';
  static const _updatedAtFieldName = 'updated_at';

  Future<void> createEvent(AppEvent event) async {
    final currentUser = firebaseAuth.currentUser;
    final now = DateTime.now();

    await firebaseFirestore.collection(_collectionName).doc().set(
      <String, dynamic>{
        _documentVersionFieldName: 1,
        _uidFieldName: currentUser.uid,
        _descriptionFieldName: event.description,
        _typeIdFieldName: event.type?.id,
        _questRankIdFieldName: event.questRank?.id,
        _targetLevelIdFieldName: event.targetLevel?.id,
        _playTimeIdFieldName: event.playTime?.id,
        _isClosedFieldName: false,
        _commentCountFieldName: 0,
        _createdAtFieldName: now,
        _updatedAtFieldName: now,
      },
    );
  }

  Future<AppEvent> getEvent(String eventId) async {
    final doc =
        await firebaseFirestore.collection(_collectionName).doc(eventId).get();
    if (doc.data() == null) {
      return null; // 募集がすでに削除されている場合
    }
    return _getEventFromDocument(doc);
  }

  // TODO(Fukky21): getEventと統合する
  Future<FirebaseEventResponse> getEvents(FirebaseEventQuery eventQuery) async {
    Query query;

    query = firebaseFirestore
        .collection(_collectionName)
        .orderBy('updated_at', descending: true);
    if (eventQuery?.lastVisible != null) {
      query = query.startAfterDocument(eventQuery.lastVisible);
    }
    if (eventQuery?.limit != null) {
      query = query.limit(eventQuery?.limit);
    }

    final snapshot = await query.get();
    final docs = snapshot.docs;

    QueryDocumentSnapshot lastVisible;
    if (docs.isNotEmpty) {
      // どこまでデータを取得したかを保持しておく
      lastVisible = docs[docs.length - 1];
    }

    final events = <AppEvent>[];
    for (final doc in docs) {
      events.add(_getEventFromDocument(doc));
    }

    return FirebaseEventResponse(events: events, lastVisible: lastVisible);
  }

  // TODO(Fukky21): 後で削除する(ダミー募集作成メソッド)
  Future<void> createDummyEvents(BuildContext context) async {
    const count = 10;
    const firstIndex = 0;
    final currentUser = firebaseAuth.currentUser;

    for (var i = firstIndex; i < count + firstIndex; i++) {
      final now = DateTime.now();
      await firebaseFirestore.collection(_collectionName).doc().set(
        <String, dynamic>{
          _documentVersionFieldName: 1,
          _uidFieldName: currentUser.uid,
          _descriptionFieldName: 'これはダミー募集${i + 1}です。',
          _typeIdFieldName: 1 + math.Random().nextInt(EventType.values.length),
          _questRankIdFieldName:
              1 + math.Random().nextInt(EventQuestRank.values.length),
          _targetLevelIdFieldName:
              1 + math.Random().nextInt(EventTargetLevel.values.length),
          _playTimeIdFieldName:
              1 + math.Random().nextInt(EventPlayTime.values.length),
          _isClosedFieldName: false,
          _commentCountFieldName: 0,
          _createdAtFieldName: now,
          _updatedAtFieldName: now,
        },
      );
      debugPrint('ダミー募集${i + 1}を作成しました');
    }
    showSnackBar(context, 'ダミー募集を$count個作成しました');
  }

  AppEvent _getEventFromDocument(DocumentSnapshot doc) {
    final data = doc.data();

    return AppEvent(
      id: doc.id,
      uid: data[_uidFieldName] as String,
      description: data[_descriptionFieldName] as String,
      type: getEventType(id: data[_typeIdFieldName] as int),
      questRank: getEventQuestRank(id: data[_questRankIdFieldName] as int),
      targetLevel: getEventTargetLevel(
        id: data[_targetLevelIdFieldName] as int,
      ),
      playTime: getEventPlayTime(id: data[_playTimeIdFieldName] as int),
      isClosed: data[_isClosedFieldName] as bool,
      commentCount: data[_commentCountFieldName] as int,
      createdAt: (data[_createdAtFieldName] as Timestamp)?.toDate(),
      updatedAt: (data[_updatedAtFieldName] as Timestamp)?.toDate(),
    );
  }
}

class FirebaseEventQuery {
  FirebaseEventQuery({
    this.limit,
    this.lastVisible,
  });

  final int limit;
  final QueryDocumentSnapshot lastVisible;
}

class FirebaseEventResponse {
  FirebaseEventResponse({
    this.events,
    this.lastVisible,
  });

  final List<AppEvent> events;
  final QueryDocumentSnapshot lastVisible;
}
