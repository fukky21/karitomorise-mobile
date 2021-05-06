import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/index.dart';
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
  static const uidFieldName = 'uid';
  static const bodyFieldName = 'body';
  static const bodyUnigramTokenMapFieldName = 'body_unigram_token_map';
  static const bodyBigramTokenMapFieldName = 'body_bigram_token_map';
  static const timeBlockFieldName = 'time_block';
  static const replyToIdFieldName = 'reply_to_id';
  static const replyFromIdListFieldName = 'reply_from_id_list';
  static const createdAtFieldName = 'created_at';
  static const updatedAtFieldName = 'updated_at';

  Future<void> createPost({@required String body, int replyToId}) async {
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
      final newPostCount = currentPostCount + 1;

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

      transaction.set(
        firebaseFirestore.collection(collectionName).doc('$newPostCount'),
        <String, dynamic>{
          documentVersionFieldName: 1,
          uidFieldName: uid,
          bodyFieldName: body,
          bodyUnigramTokenMapFieldName: unigramTokenMap,
          bodyBigramTokenMapFieldName: bigramTokenMap,
          timeBlockFieldName: _getTimeBlock(now),
          replyToIdFieldName: replyToId,
          replyFromIdListFieldName: <int>[],
          createdAtFieldName: now,
          updatedAtFieldName: now,
        },
      );

      if (replyToId != null) {
        transaction.update(
          firebaseFirestore.collection(collectionName).doc('$replyToId'),
          <String, dynamic>{
            replyFromIdListFieldName: FieldValue.arrayUnion(
              <int>[newPostCount],
            ),
          },
        );
      }

      transaction.update(
        ref,
        <String, int>{currentPostCountFieldName: newPostCount},
      );
    });
  }

  Future<Map<String, dynamic>> getNewPosts({
    QueryDocumentSnapshot lastVisible,
  }) async {
    var query = firebaseFirestore
        .collection(collectionName)
        .orderBy(createdAtFieldName, descending: true);

    if (lastVisible != null) {
      query = query.startAfterDocument(lastVisible);
    }
    query = query.limit(10);

    final snapshot = await query.get();
    final docs = snapshot.docs;

    QueryDocumentSnapshot newLastVisible;
    final posts = <Post>[];
    if (docs.isNotEmpty) {
      newLastVisible = docs[docs.length - 1]; // どこまでデータを取得したか保持しておく
      for (final doc in docs) {
        final post = _getPostFromDocument(doc);
        posts.add(post);
      }
    }

    return <String, dynamic>{
      'last_visible': newLastVisible,
      'posts': posts,
    };
  }

  Future<List<Post>> getPostsByKeyword({@required String keyword}) async {
    final words = <String>[]; // 例: [リオレウス, リオレイア]
    // 半角/全角スペースで文字列を分割する
    keyword.split(RegExp(r' |　')).forEach(
      (word) {
        if (word.isNotEmpty) {
          words.add(word.toLowerCase());
        }
      },
    );
    final tokens = <String>[]; // 例: [リオ, オレ, レウ, ウス, 珠]
    for (final word in words) {
      if (word.length == 1) {
        if (!tokens.contains(word)) {
          // 重複して追加するとqueryエラーが発生するので注意
          tokens.add(word);
        }
      } else {
        for (var i = 0; i < word.length - 1; i++) {
          final token = word.substring(i, i + 2);
          if (!tokens.contains(token)) {
            // 重複して追加するとqueryエラーが発生するので注意
            tokens.add(token);
          }
        }
      }
    }

    Query query = firebaseFirestore.collection(collectionName);

    for (final token in tokens) {
      if (token.length == 1) {
        query = query.where(
          '$bodyUnigramTokenMapFieldName.$token',
          isEqualTo: true,
        );
      } else {
        query = query.where(
          '$bodyBigramTokenMapFieldName.$token',
          isEqualTo: true,
        );
      }
    }

    // 3時間前までの時刻ブロックに所属する投稿のみを対象にする
    final now = DateTime.now();
    query = query.where(
      timeBlockFieldName,
      whereIn: <String>[
        _getTimeBlock(now),
        _getTimeBlock(now.add(const Duration(hours: 1) * -1)),
        _getTimeBlock(now.add(const Duration(hours: 2) * -1)),
        _getTimeBlock(now.add(const Duration(hours: 3) * -1)),
      ],
    );

    final snapshot = await query.get();
    final docs = snapshot.docs;

    final posts = <Post>[];
    for (final doc in docs) {
      final post = _getPostFromDocument(doc);
      posts.add(post);
    }

    // idでソートする
    posts.sort((a, b) => b.id.compareTo(a.id));

    return posts;
  }

  Future<List<Post>> getThread({@required int replyToId}) async {
    // 再帰的に返信を取得する
    Future<List<Post>> _func({
      @required int id,
      @required List<Post> posts,
    }) async {
      final doc =
          await firebaseFirestore.collection(collectionName).doc('$id').get();
      final post = _getPostFromDocument(doc);
      posts.add(post);
      if (post.replyToId == null) {
        return posts;
      } else {
        return _func(id: post.replyToId, posts: posts);
      }
    }

    return _func(id: replyToId, posts: []);
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

  Post _getPostFromDocument(DocumentSnapshot doc) {
    final data = doc.data();

    final replyFromIdList = <int>[];
    for (final id in data[replyFromIdListFieldName] as List<dynamic>) {
      replyFromIdList.add(id as int);
    }

    return Post(
      id: int.parse(doc.id),
      uid: data[uidFieldName] as String,
      body: data[bodyFieldName] as String,
      replyToId: data[replyToIdFieldName] as int,
      replyFromIdList: replyFromIdList,
      createdAt: (data[createdAtFieldName] as Timestamp)?.toDate(),
    );
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
