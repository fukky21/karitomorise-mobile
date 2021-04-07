import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/index.dart';

class FirebaseEventCommentRepository {
  FirebaseEventCommentRepository({
    @required this.firebaseAuth,
    @required this.firebaseFirestore,
  });

  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firebaseFirestore;

  static const _parentCollectionName = 'events';
  static const _collectionName = 'comments';
  static const _idFieldName = 'id';
  static const _documentVersionFieldName = 'document_version';
  static const _uidFieldName = 'uid';
  static const _messageFieldName = 'message';
  static const _createdAtFieldName = 'created_at';
  static const _updatedAtFieldName = 'updated_at';

  Future<void> createEventComment(String eventId, String message) async {
    final currentUser = firebaseAuth.currentUser;
    final id = firebaseFirestore
        .collection(_parentCollectionName)
        .doc(eventId)
        .collection(_collectionName)
        .doc()
        .id;
    final now = DateTime.now();

    await firebaseFirestore.runTransaction((transaction) async {
      transaction
        ..set(
          firebaseFirestore
              .collection(_parentCollectionName)
              .doc(eventId)
              .collection(_collectionName)
              .doc(id),
          <String, dynamic>{
            _idFieldName: id,
            _documentVersionFieldName: 1,
            _uidFieldName: currentUser.uid,
            _messageFieldName: message,
            _createdAtFieldName: now,
            _updatedAtFieldName: now,
          },
        )
        ..update(
          firebaseFirestore.collection(_parentCollectionName).doc(eventId),
          <String, dynamic>{
            'comment_count': FieldValue.increment(1),
          },
        );
    });
  }

  Stream<QuerySnapshot> getSnapshots(String eventId) {
    return firebaseFirestore
        .collection(_parentCollectionName)
        .doc(eventId)
        .collection(_collectionName)
        .orderBy(_createdAtFieldName, descending: true)
        .snapshots();
  }

  EventComment getEventCommentFromDocument(DocumentSnapshot doc) {
    final data = doc.data();

    return EventComment(
      id: doc.id,
      uid: data[_uidFieldName] as String,
      message: data[_messageFieldName] as String,
      createdAt: (data[_createdAtFieldName] as Timestamp)?.toDate(),
    );
  }
}
