import 'package:flutter/material.dart';

class Post {
  Post({
    @required this.id,
    @required this.uid,
    @required this.body,
    @required this.replyToId,
    @required this.replyFromIdList,
    @required this.createdAt,
  });

  final int id;
  final String uid;
  final String body;
  final int replyToId;
  final List<int> replyFromIdList;
  final DateTime createdAt;
}
