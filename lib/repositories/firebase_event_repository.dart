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
  static const _subCollectionName = '_events';
  static const _idFieldName = 'id';
  static const _documentVersionFieldName = 'document_version';
  static const _uidFieldName = 'uid';
  static const _descriptionFieldName = 'description';
  static const _typeIdFieldName = 'type_id';
  static const _questRankIdFieldName = 'quest_rank_id';
  static const _targetLevelIdFieldName = 'target_level_id';
  static const _playTimeIdFieldName = 'play_time_id';
  static const _isClosedFieldName = 'is_closed';
  static const _commentCountFieldName = 'comment_count';
  static const _uniGramTokenMapFieldName = 'uni_gram_token_map';
  static const _biGramTokenMapFieldName = 'bi_gram_token_map';
  static const _timeBlockTagFieldName = 'time_block_tag';
  static const _createdAtFieldName = 'created_at';
  static const _updatedAtFieldName = 'updated_at';

  Future<void> createEvent(AppEvent event) async {
    final currentUser = firebaseAuth.currentUser;
    final id = firebaseFirestore.collection(_subCollectionName).doc().id;
    final now = DateTime.now();

    final description = event.description;
    final uniGramTokenMap = <String, bool>{}; // 検索用 uni-gram
    final biGramTokenMap = <String, bool>{}; // 検索用 bi-gram
    if (description.isNotEmpty) {
      for (var i = 0; i < description.length; i++) {
        final token = description.substring(i, i + 1).toLowerCase();
        // 重複して追加しないようにする
        if (uniGramTokenMap[token] == null) {
          uniGramTokenMap[token] = true;
        }
      }
      for (var i = 0; i < description.length - 1; i++) {
        final token = description.substring(i, i + 2).toLowerCase();
        // 重複して追加しないようにする
        if (biGramTokenMap[token] == null) {
          biGramTokenMap[token] = true;
        }
      }
    }

    await firebaseFirestore.runTransaction((transaction) async {
      transaction
        ..set(
          firebaseFirestore.collection(_subCollectionName).doc(id),
          <String, dynamic>{
            _idFieldName: id,
            _documentVersionFieldName: 1,
            _uniGramTokenMapFieldName: uniGramTokenMap,
            _biGramTokenMapFieldName: biGramTokenMap,
            _timeBlockTagFieldName: _getTimeTag(now),
            _createdAtFieldName: now,
            _updatedAtFieldName: now,
          },
        )
        ..set(
          firebaseFirestore.collection(_collectionName).doc(id),
          <String, dynamic>{
            _idFieldName: id,
            _documentVersionFieldName: 1,
            _uidFieldName: currentUser.uid,
            _descriptionFieldName: description,
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
    });
  }

  Future<AppEvent> getEvent(String eventId) async {
    final doc =
        await firebaseFirestore.collection(_collectionName).doc(eventId).get();
    if (doc.data() == null) {
      return null; // 募集がすでに削除されている場合
    }
    return _getEventFromDocument(doc);
  }

  Future<EventResponse> find(EventQuery eventQuery) async {
    Query query = firebaseFirestore.collection(_collectionName);

    if (eventQuery.eventIds != null) {
      if (eventQuery.eventIds.isEmpty) {
        // キーワード検索のヒット数が0のとき、eventIdsに空の配列が渡ってくる
        return EventResponse(events: []);
      }
      query = query.where(_idFieldName, whereIn: eventQuery.eventIds);
    }

    query = query.orderBy(_updatedAtFieldName, descending: true);

    if (eventQuery.lastVisible != null) {
      query = query.startAfterDocument(eventQuery.lastVisible);
    }

    if (eventQuery.limit != null) {
      query = query.limit(eventQuery.limit);
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

  Future<List<String>> getEventIdsByKeywords(List<String> keywords) async {
    Query query = firebaseFirestore.collection(_subCollectionName);

    final tokens = <String>[]; // 例: [リオ, オレ, レウ, ウス, 珠]
    for (final keyword in keywords) {
      if (keyword.length == 1) {
        // 重複して追加しないようにする(重複するとqueryエラーが発生するので注意)
        if (!tokens.contains(keyword)) {
          tokens.add(keyword);
        }
      } else {
        for (var i = 0; i < keyword.length - 1; i++) {
          final token = keyword.substring(i, i + 2);
          // 重複して追加しないようにする(重複するとqueryエラーが発生するので注意)
          if (!tokens.contains(token)) {
            tokens.add(token);
          }
        }
      }
    }

    for (final token in tokens) {
      if (token.length == 1) {
        query = query.where(
          '$_uniGramTokenMapFieldName.$token',
          isEqualTo: true,
        );
      } else {
        query = query.where(
          '$_biGramTokenMapFieldName.$token',
          isEqualTo: true,
        );
      }
    }
    // 現在の時刻ブロックと1つ前の時刻ブロックに属する募集のみを検索対象にする
    final now = DateTime.now();
    final oneHourAgo = now.add(const Duration(hours: 1) * -1);
    query = query.where(
      _timeBlockTagFieldName,
      whereIn: <String>[_getTimeTag(now), _getTimeTag(oneHourAgo)],
    );

    final snapshot = await query.get();
    final docs = snapshot.docs;

    final eventIds = <String>[];
    for (final doc in docs) {
      if (doc.data() != null) {
        eventIds.add(doc.id);
      }
    }
    return eventIds;
  }

  // TODO(Fukky21): 後で削除する(ダミー募集作成メソッド)
  Future<void> createDummyEvents(BuildContext context) async {
    const count = 10;
    const firstIndex = 0;

    for (var i = firstIndex; i < count + firstIndex; i++) {
      await createEvent(
        AppEvent(
          description: 'これはダミー募集${i + 1}です。',
          type: getEventType(
            id: 1 + math.Random().nextInt(EventType.values.length),
          ),
          questRank: getEventQuestRank(
            id: 1 + math.Random().nextInt(EventQuestRank.values.length),
          ),
          targetLevel: getEventTargetLevel(
            id: 1 + math.Random().nextInt(EventTargetLevel.values.length),
          ),
          playTime: getEventPlayTime(
            id: 1 + math.Random().nextInt(EventPlayTime.values.length),
          ),
        ),
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
    this.eventIds,
    this.lastVisible,
  });

  final int limit;
  final String keyword;
  final List<String> eventIds;
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
