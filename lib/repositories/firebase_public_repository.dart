import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FirebasePublicRepository {
  FirebasePublicRepository({@required this.firebaseFirestore});

  final FirebaseFirestore firebaseFirestore;

  static const collectionName = 'public';
  static const documentVersionFieldName = 'document_version';
  static const staticDocumentName = 'static';
  static const dynamicDocumentName = 'dynamic';
  static const hotwordsFieldName = 'hotwords';
  static const currentPostCountFieldName = 'current_post_count';

  Future<List<String>> getHotwords() async {
    final doc = await firebaseFirestore
        .collection(collectionName)
        .doc(staticDocumentName)
        .get();
    final data = doc.data();

    final hotwords = <String>[];
    if (data != null) {
      for (final hotword in data[hotwordsFieldName] as List<dynamic>) {
        hotwords.add(hotword as String);
      }
    }
    return hotwords;
  }
}
