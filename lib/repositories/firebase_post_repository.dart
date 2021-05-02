import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FirebasePostRepository {
  FirebasePostRepository({
    @required this.firebaseAuth,
    @required this.firebaseFirestore,
  });

  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firebaseFirestore;

  Future<void> create({@required String body, int replyToNumber}) async {
    final currentUser = firebaseAuth.currentUser;
    final now = DateTime.now();

    String uid;
    if (currentUser != null && !currentUser.isAnonymous) {
      uid = currentUser.uid;
    }

    await firebaseFirestore.runTransaction((transaction) async {
      final ref = firebaseFirestore.collection('public').doc('_data');
      final snapshot = await transaction.get(ref);
      final currentPostCount = snapshot.data()['current_post_count'] as int;

      final unigramTokenMap = <String, bool>{};
      final bigramTokenMap = <String, bool>{};
      if (body.isNotEmpty) {
        for (var i = 0; i < body.length; i++) {
          final token = body.substring(i, i + 1).toLowerCase();
          // 重複して追加しないように注意
          if (unigramTokenMap[token] == null) {
            unigramTokenMap[token] = true;
          }
        }
        for (var i = 0; i < body.length - 1; i++) {
          final token = body.substring(i, i + 2).toLowerCase();
          // 重複して追加しないように注意
          if (bigramTokenMap[token] == null) {
            bigramTokenMap[token] = true;
          }
        }
      }

      transaction
        ..set(
          firebaseFirestore.collection('posts').doc(),
          <String, dynamic>{
            'number': currentPostCount + 1,
            'document_version': 1,
            'uid': uid,
            'body': body,
            'body_unigram_token_map': unigramTokenMap,
            'body_bigram_token_map': bigramTokenMap,
            'time_block': _getTimeBlock(now),
            'reply_to_number': replyToNumber,
            'reply_from_numbers': <int>[],
            'created_at': now,
            'updated_at': now,
          },
        )
        ..update(
          ref,
          <String, int>{'current_post_count': currentPostCount + 1},
        );
    });
  }

  /// 例: 2021-03-26-10-00
  String _getTimeBlock(DateTime dateTime) {
    final year = dateTime.year.toString();
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    final hour = dateTime.hour.toString().padLeft(2, '0');

    return '$year-$month-$day-$hour-00';
  }
}
