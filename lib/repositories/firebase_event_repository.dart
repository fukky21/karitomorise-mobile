import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/index.dart';

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
      createdAt: (data[_createdAtFieldName] as Timestamp)?.toDate(),
      updatedAt: (data[_updatedAtFieldName] as Timestamp)?.toDate(),
    );
  }
}
