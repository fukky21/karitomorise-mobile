import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/post.dart';

class FirebasePostRepository {
  final _firebaseAuth = FirebaseAuth.instance;
  final _firebaseFirestore = FirebaseFirestore.instance;

  Future<void> createPost({@required String body, int replyToNumber}) async {
    final currentUser = _firebaseAuth.currentUser;
    final now = DateTime.now();

    if (currentUser != null) {
      final uid = currentUser.isAnonymous ? null : currentUser.uid;
      await _firebaseFirestore.runTransaction((transaction) async {
        final docRef = _firebaseFirestore.collection('public').doc('dynamic');
        final snapshot = await transaction.get(docRef);
        final currentPostCount = snapshot.data()['current_post_count'] as int;
        final newPostCount = currentPostCount + 1;

        final unigramTokenMap = <String, bool>{};
        final bigramTokenMap = <String, bool>{};

        if (body.isNotEmpty) {
          for (var i = 0; i < body.length; i++) {
            final token = body.substring(i, i + 1).toLowerCase();
            if (unigramTokenMap[token] == null) {
              // 重複して追加しないように注意
              unigramTokenMap[token] = true;
            }
          }
          for (var i = 0; i < body.length - 1; i++) {
            final token = body.substring(i, i + 2).toLowerCase();
            if (bigramTokenMap[token] == null) {
              // 重複して追加しないように注意
              bigramTokenMap[token] = true;
            }
          }
        }

        transaction.set(
          _firebaseFirestore.collection('posts').doc(),
          <String, dynamic>{
            'document_version': 1,
            'number': newPostCount,
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
        );

        if (replyToNumber != null) {
          final snapshot = await _firebaseFirestore
              .collection('posts')
              .where('number', isEqualTo: replyToNumber)
              .get();

          transaction.update(
            snapshot.docs.first.reference,
            <String, dynamic>{
              'reply_from_numbers': FieldValue.arrayUnion(
                <int>[newPostCount],
              ),
            },
          );
        }

        transaction.update(
          docRef,
          <String, int>{'current_post_count': newPostCount},
        );
      });
    }
  }

  Future<Map<String, dynamic>> getNewPosts({
    QueryDocumentSnapshot lastVisible,
  }) async {
    var query = _firebaseFirestore
        .collection('posts')
        .orderBy('created_at', descending: true);

    if (lastVisible != null) {
      query = query.startAfterDocument(lastVisible);
    }
    query = query.limit(10);

    final snapshot = await query.get();
    final snapshots = snapshot.docs;

    QueryDocumentSnapshot newLastVisible;
    final posts = <Post>[];
    if (snapshots.isNotEmpty) {
      // どこまでデータを取得したか保持しておく
      newLastVisible = snapshots[snapshots.length - 1];
      for (final _snapshot in snapshots) {
        final post = _parse(_snapshot);
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

    Query query = _firebaseFirestore.collection('posts');

    for (final token in tokens) {
      if (token.length == 1) {
        query = query.where('body_unigram_token_map.$token', isEqualTo: true);
      } else {
        query = query.where('body_bigram_token_map.$token', isEqualTo: true);
      }
    }

    // 3時間前までの投稿のみを対象にする
    final now = DateTime.now();
    query = query.where(
      'time_block',
      whereIn: <String>[
        _getTimeBlock(now),
        _getTimeBlock(now.add(const Duration(hours: 1) * -1)),
        _getTimeBlock(now.add(const Duration(hours: 2) * -1)),
        _getTimeBlock(now.add(const Duration(hours: 3) * -1)),
      ],
    );

    final snapshot = await query.get();
    final snapshots = snapshot.docs;

    final posts = <Post>[];
    for (final _snapshot in snapshots) {
      final post = _parse(_snapshot);
      posts.add(post);
    }

    // number順に並び替える
    posts.sort((a, b) => b.number.compareTo(a.number));

    return posts;
  }

  Future<List<Post>> getThread({@required int replyToNumber}) async {
    // 再帰的に返信を取得する
    Future<List<Post>> _function({
      @required int number,
      @required List<Post> posts,
    }) async {
      final snapshot = await _firebaseFirestore
          .collection('posts')
          .where('number', isEqualTo: number)
          .get();

      final post = _parse(snapshot.docs.first);
      posts.add(post);
      if (post.replyToNumber != null) {
        return _function(number: post.replyToNumber, posts: posts);
      } else {
        return posts;
      }
    }

    return _function(number: replyToNumber, posts: []);
  }

  Future<List<Post>> getReplies({@required List<int> replyFromNumbers}) async {
    final posts = <Post>[];

    for (final number in replyFromNumbers) {
      final snapshot = await _firebaseFirestore
          .collection('posts')
          .where('number', isEqualTo: number)
          .get();
      final post = _parse(snapshot.docs.first);
      posts.add(post);
    }

    // id順に並び替える
    posts.sort((a, b) => a.number.compareTo(b.number));

    return posts;
  }

  // TODO(fukky21): 後で削除する
  Future<void> createDummyPosts() async {
    const count = 10;
    const firstIndex = 0; // bodyに入る数値を変更する

    for (var i = firstIndex; i < count + firstIndex; i++) {
      await createPost(
        body: 'これはダミー投稿${i + 1}です。',
      );
      debugPrint('ダミー投稿${i + 1}を作成しました');
    }
  }

  Post _parse(DocumentSnapshot snapshot) {
    final data = snapshot.data();

    final replyFromNumbers = <int>[];
    for (final id in data['reply_from_numbers'] as List<dynamic>) {
      replyFromNumbers.add(id as int);
    }

    return Post(
      id: snapshot.id,
      number: data['number'] as int,
      uid: data['uid'] as String,
      body: data['body'] as String,
      replyToNumber: data['reply_to_number'] as int,
      replyFromNumbers: replyFromNumbers,
      createdAt: (data['created_at'] as Timestamp)?.toDate(),
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
