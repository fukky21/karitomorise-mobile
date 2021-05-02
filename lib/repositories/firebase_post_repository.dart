import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'firebase_public_repository.dart';

class FirebasePostRepository {
  FirebasePostRepository({
    @required this.firebaseAuth,
    @required this.firebaseFirestore,
  });

  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firebaseFirestore;

  static const collectionName = 'posts';
  static const documentVersionFieldName = 'document_version';
  static const numberFieldName = 'number';
  static const uidFieldName = 'uid';
  static const bodyFieldName = 'body';
  static const bodyUnigramTokenMap = 'body_unigram_token_map';
  static const bodyBigramTokenMap = 'body_bigram_token_map';
  static const timeBlockFieldName = 'time_block';
  static const replyToNumberFieldName = 'reply_to_number';
  static const replyFromNumbers = 'reply_from_numbers';
  static const createdAtFieldName = 'created_at';
  static const updatedAtFieldName = 'updated_at';

  Future<void> createPost({@required String body, int replyToNumber}) async {
    final currentUser = firebaseAuth.currentUser;
    final now = DateTime.now();
    final publicCollectionName = FirebasePublicRepository.collectionName;
    final dynamicDocumentName = FirebasePublicRepository.dynamicDocumentName;
    final currentPostCountFieldName =
        FirebasePublicRepository.currentPostCountFieldName;

    String uid;
    if (currentUser != null && !currentUser.isAnonymous) {
      uid = currentUser.uid;
    }

    await firebaseFirestore.runTransaction((transaction) async {
      final ref = firebaseFirestore
          .collection(publicCollectionName)
          .doc(dynamicDocumentName);
      final snapshot = await transaction.get(ref);
      final currentPostCount =
          snapshot.data()[currentPostCountFieldName] as int;

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
          firebaseFirestore.collection(collectionName).doc(),
          <String, dynamic>{
            documentVersionFieldName: 1,
            numberFieldName: currentPostCount + 1,
            uidFieldName: uid,
            bodyFieldName: body,
            bodyUnigramTokenMap: unigramTokenMap,
            bodyBigramTokenMap: bigramTokenMap,
            timeBlockFieldName: _getTimeBlock(now),
            replyToNumberFieldName: replyToNumber,
            replyFromNumbers: <int>[],
            createdAtFieldName: now,
            updatedAtFieldName: now,
          },
        )
        ..update(
          ref,
          <String, int>{currentPostCountFieldName: currentPostCount + 1},
        );
    });
  }

  // TODO(fukky21): 後で削除する
  Future<void> createDummyPosts() async {
    const count = 10;
    const firstIndex = 0; // bodyに入る数値を変更する

    for (var i = firstIndex; i < count + firstIndex; i++) {
      await createPost(
        body: 'これはダミー投稿${i + 1}です。これはダミー投稿${i + 1}です。これはダミー投稿${i + 1}です。',
      );
      debugPrint('ダミー投稿${i + 1}を作成しました');
    }
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
