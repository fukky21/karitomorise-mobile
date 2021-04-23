import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FirebasePublicRepository {
  FirebasePublicRepository({
    @required this.firebaseAuth,
    @required this.firebaseFirestore,
  });

  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firebaseFirestore;

  static const _collectionName = 'public';
  static const _documentVersionFieldName = 'document_version';
  static const _dataDocumentName = 'data';
  static const _hotwordsFieldName = 'hotwords';

  Future<List<String>> getHotwords(String eventId) async {
    final doc = await firebaseFirestore
        .collection(_collectionName)
        .doc(_dataDocumentName)
        .get();
    final data = doc.data();

    final hotwords = <String>[];
    if (data != null) {
      for (final hotword in data[_hotwordsFieldName] as List<dynamic>) {
        hotwords.add(hotword as String);
      }
    }

    return hotwords;
  }
}
