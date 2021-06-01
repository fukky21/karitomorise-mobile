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

    final uid = currentUser.isAnonymous ? null : currentUser.uid;
    await _firebaseFirestore.runTransaction((transaction) async {
      final docRef = _firebaseFirestore.collection('public').doc('dynamic');
      final snapshot = await transaction.get(docRef);
      final currentPostCount = snapshot.data()['currentPostCount'] as int;

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
          'documentVersion': 1,
          'number': currentPostCount + 1,
          'uid': uid,
          'body': body,
          'bodyUnigramTokenMap': unigramTokenMap,
          'bodyBigramTokenMap': bigramTokenMap,
          'timeBlock': _getTimeBlock(now),
          'replyToNumber': replyToNumber,
          'replyFromNumbers': <int>[],
          'createdAt': now,
          'updatedAt': now,
        },
      );

      if (replyToNumber != null) {
        final snapshot = await _firebaseFirestore
            .collection('posts')
            .where('number', isEqualTo: replyToNumber)
            .get();
        final docs = snapshot.docs;

        if (docs.isEmpty) {
          throw Exception('Post document is not found.');
        }

        if (docs.length > 1) {
          throw Exception('The same number post exists.');
        }

        transaction.update(
          docs.first.reference,
          <String, dynamic>{
            'replyFromNumbers': FieldValue.arrayUnion(
              <int>[currentPostCount + 1],
            ),
          },
        );
      }

      transaction.update(
        docRef,
        <String, int>{'currentPostCount': currentPostCount + 1},
      );
    });
  }

  Future<Post> getPost({@required int number}) async {
    final snapshot = await _firebaseFirestore
        .collection('posts')
        .where('number', isEqualTo: number)
        .get();
    final docs = snapshot.docs;

    if (docs.isEmpty) {
      throw Exception('Post document is not found.');
    }

    if (docs.length > 1) {
      throw Exception('The same number post exists.');
    }

    final post = _parse(docs.first);
    return post;
  }

  Future<Map<String, dynamic>> getNewPosts({
    QueryDocumentSnapshot lastVisible,
  }) async {
    var query = _firebaseFirestore
        .collection('posts')
        .orderBy('createdAt', descending: true);
    if (lastVisible != null) {
      query = query.startAfterDocument(lastVisible);
    }
    query = query.limit(10);

    final snapshot = await query.get();
    final docs = snapshot.docs;

    QueryDocumentSnapshot newLastVisible;
    final posts = <Post>[];
    if (docs.isNotEmpty) {
      // どこまでデータを取得したか保持しておく
      newLastVisible = docs[docs.length - 1];
      for (final doc in docs) {
        final post = _parse(doc);
        posts.add(post);
      }
    }

    return <String, dynamic>{
      'lastVisible': newLastVisible,
      'posts': posts,
    };
  }

  Future<List<Post>> getPostsByKeyword({@required String keyword}) async {
    final words = <String>[]; // 例: [リオレウス, リオレイア]
    // 半角or全角スペースで文字列を分割する
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

    // 禁則文字を弾く
    final validatedTokens = <String>[];
    for (final token in tokens) {
      if (!token.contains(RegExp(r'\.|~|\*|/|\[|\]'))) {
        validatedTokens.add(token);
      }
    }

    if (validatedTokens.isEmpty) {
      // 禁則文字を弾いた時点で検索トークンがなくなってしまった場合は検索結果なしとする
      return [];
    }

    Query query = _firebaseFirestore.collection('posts');

    for (final validatedToken in validatedTokens) {
      if (validatedToken.length == 1) {
        query = query.where(
          'bodyUnigramTokenMap.$validatedToken',
          isEqualTo: true,
        );
      } else {
        query = query.where(
          'bodyBigramTokenMap.$validatedToken',
          isEqualTo: true,
        );
      }
    }

    // 6時間前までの投稿を対象にする
    final now = DateTime.now();
    query = query.where(
      'timeBlock',
      whereIn: <String>[
        _getTimeBlock(now),
        _getTimeBlock(now.add(const Duration(hours: 1) * -1)),
        _getTimeBlock(now.add(const Duration(hours: 2) * -1)),
        _getTimeBlock(now.add(const Duration(hours: 3) * -1)),
        _getTimeBlock(now.add(const Duration(hours: 4) * -1)),
        _getTimeBlock(now.add(const Duration(hours: 5) * -1)),
        _getTimeBlock(now.add(const Duration(hours: 6) * -1)),
      ],
    );

    final snapshot = await query.get();
    final docs = snapshot.docs;

    final posts = <Post>[];
    for (final doc in docs) {
      final post = _parse(doc);
      posts.add(post);
    }

    // number順に並び替える
    posts.sort((a, b) => b.number.compareTo(a.number));

    return posts;
  }

  Future<List<Post>> getThread({@required int replyToNumber}) async {
    Future<List<Post>> _function({
      @required int number,
      @required List<Post> posts,
    }) async {
      final snapshot = await _firebaseFirestore
          .collection('posts')
          .where('number', isEqualTo: number)
          .get();
      final docs = snapshot.docs;

      if (docs.isEmpty) {
        throw Exception('Post document is not found.');
      }

      if (docs.length > 1) {
        throw Exception('The same number post exists.');
      }

      final post = _parse(docs.first);
      posts.add(post);

      if (post.replyToNumber != null) {
        return _function(number: post.replyToNumber, posts: posts);
      } else {
        return posts;
      }
    }

    // 再帰的に返信を取得する
    return _function(number: replyToNumber, posts: []);
  }

  Future<List<Post>> getReplies({@required List<int> replyFromNumbers}) async {
    final posts = <Post>[];

    for (final number in replyFromNumbers) {
      final snapshot = await _firebaseFirestore
          .collection('posts')
          .where('number', isEqualTo: number)
          .get();
      final docs = snapshot.docs;

      if (docs.isEmpty) {
        throw Exception('Post document is not found.');
      }

      if (docs.length > 1) {
        throw Exception('The same number post exists.');
      }

      final post = _parse(docs.first);
      posts.add(post);
    }

    // id順に並び替える
    posts.sort((a, b) => a.number.compareTo(b.number));

    return posts;
  }

  Post _parse(DocumentSnapshot doc) {
    final data = doc.data() as Map;

    final replyFromNumbers = <int>[];
    for (final id in data['replyFromNumbers'] as List<dynamic>) {
      replyFromNumbers.add(id as int);
    }

    return Post(
      id: doc.id,
      number: data['number'] as int,
      uid: data['uid'] as String,
      body: data['body'] as String,
      replyToNumber: data['replyToNumber'] as int,
      replyFromNumbers: replyFromNumbers,
      createdAt: (data['createdAt'] as Timestamp)?.toDate(),
    );
  }

  // 例: 2021-03-26-10-00
  String _getTimeBlock(DateTime dateTime) {
    final year = dateTime.year.toString();
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    final hour = dateTime.hour.toString().padLeft(2, '0');

    return '$year-$month-$day-$hour-00';
  }
}
