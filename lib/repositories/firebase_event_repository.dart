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
  static const _descriptionTokenMapFieldName = 'description_token_map';
  static const _typeIdFieldName = 'type_id';
  static const _questRankIdFieldName = 'quest_rank_id';
  static const _targetLevelIdFieldName = 'target_level_id';
  static const _playTimeIdFieldName = 'play_time_id';
  static const _isClosedFieldName = 'is_closed';
  static const _commentCountFieldName = 'comment_count';
  static const _timeBlockTagFieldName = 'time_block_tag';
  static const _createdAtFieldName = 'created_at';
  static const _updatedAtFieldName = 'updated_at';

  Future<void> createEvent(AppEvent event) async {
    final currentUser = firebaseAuth.currentUser;
    final now = DateTime.now();

    final description = event.description;
    final descriptionTokenMap = <String, bool>{}; // 検索用 2-gram
    if (description.isNotEmpty) {
      for (var i = 0; i < description.length - 1; i++) {
        final token = description.substring(i, i + 2).toLowerCase();
        // 重複して追加しないようにする
        if (descriptionTokenMap[token] == null) {
          descriptionTokenMap[token] = true;
        }
      }
    }

    await firebaseFirestore.collection(_collectionName).doc().set(
      <String, dynamic>{
        _documentVersionFieldName: 1,
        _uidFieldName: currentUser.uid,
        _descriptionFieldName: description,
        _descriptionTokenMapFieldName: descriptionTokenMap,
        _typeIdFieldName: event.type?.id,
        _questRankIdFieldName: event.questRank?.id,
        _targetLevelIdFieldName: event.targetLevel?.id,
        _playTimeIdFieldName: event.playTime?.id,
        _isClosedFieldName: false,
        _commentCountFieldName: 0,
        _timeBlockTagFieldName: _getTimeTag(now),
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

  Future<EventResponse> searchEvents(EventQuery searchEventsQuery) async {
    Query query = firebaseFirestore.collection(_collectionName);

    if (searchEventsQuery?.keyword != null) {
      final keywords = <String>[];
      // 半角/全角スペースで文字列を分割する
      searchEventsQuery.keyword.split(RegExp(r' |　')).forEach(
        (keyword) {
          if (keyword.isNotEmpty) {
            keywords.add(keyword.toLowerCase()); // 例: [リオレウス, リオレイア]
          }
        },
      );
      final searchTokens = <String>[];
      for (final keyword in keywords) {
        for (var i = 0; i < keyword.length - 1; i++) {
          final token = keyword.substring(i, i + 2);
          // 重複して追加しないようにする(重複するとqueryエラーが発生するので注意)
          if (!searchTokens.contains(token)) {
            searchTokens.add(token); // 例: [リオ, オレ, レウ, ウス, リオ, レイ, イア]
          }
        }
      }
      for (final token in searchTokens) {
        query = query.where(
          '$_descriptionTokenMapFieldName.$token',
          isEqualTo: true,
        );
      }
      // 現在の時刻ブロックと1つ前の時刻ブロックに属する募集のみを検索対象にする
      final now = DateTime.now();
      final oneHourAgo = now.add(const Duration(hours: 1) * -1);
      query = query.where(
        _timeBlockTagFieldName,
        whereIn: <String>[_getTimeTag(now), _getTimeTag(oneHourAgo)],
      );
    }

    // Firebaseの制約でキーワード検索するときは時刻でソートできない
    if (searchEventsQuery?.keyword == null) {
      query = query.orderBy('updated_at', descending: true);
    }

    if (searchEventsQuery?.lastVisible != null) {
      query = query.startAfterDocument(searchEventsQuery.lastVisible);
    }

    if (searchEventsQuery?.limit != null) {
      query = query.limit(searchEventsQuery.limit);
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

    return EventResponse(events: events, lastVisible: lastVisible);
  }

  // TODO(Fukky21): 後で削除する(ダミー募集作成メソッド)
  Future<void> createDummyEvents(BuildContext context) async {
    const count = 10;
    const firstIndex = 0;
    final currentUser = firebaseAuth.currentUser;

    for (var i = firstIndex; i < count + firstIndex; i++) {
      final now = DateTime.now();

      final description = 'これはダミー募集${i + 1}です。';
      final descriptionTokenMap = <String, bool>{};
      if (description.isNotEmpty) {
        for (var i = 0; i < description.length - 1; i++) {
          final token = description.substring(i, i + 2).toLowerCase();
          descriptionTokenMap[token] = true;
        }
      }

      await firebaseFirestore.collection(_collectionName).doc().set(
        <String, dynamic>{
          _documentVersionFieldName: 1,
          _uidFieldName: currentUser.uid,
          _descriptionFieldName: description,
          _descriptionTokenMapFieldName: descriptionTokenMap,
          _typeIdFieldName: 1 + math.Random().nextInt(EventType.values.length),
          _questRankIdFieldName:
              1 + math.Random().nextInt(EventQuestRank.values.length),
          _targetLevelIdFieldName:
              1 + math.Random().nextInt(EventTargetLevel.values.length),
          _playTimeIdFieldName:
              1 + math.Random().nextInt(EventPlayTime.values.length),
          _isClosedFieldName: false,
          _commentCountFieldName: 0,
          _timeBlockTagFieldName: _getTimeTag(now),
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

  String _getTimeTag(DateTime dateTime) {
    final year = dateTime.year.toString();
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    final hour = dateTime.hour.toString().padLeft(2, '0');

    return '$year-$month-$day-$hour-00';
  }
}

class EventQuery {
  EventQuery({
    this.limit = 10,
    this.keyword,
    this.lastVisible,
  });

  final int limit;
  final String keyword;
  final QueryDocumentSnapshot lastVisible;
}

class EventResponse {
  EventResponse({
    this.events,
    this.lastVisible,
  });

  final List<AppEvent> events;
  final QueryDocumentSnapshot lastVisible;
}
