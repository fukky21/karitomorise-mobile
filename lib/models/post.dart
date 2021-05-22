import 'package:flutter/material.dart';

class Post {
  Post({
    @required this.id,
    @required this.uid,
    @required this.number,
    @required this.body,
    @required this.replyToNumber,
    @required this.replyFromNumbers,
    @required this.createdAt,
  });

  final String id;
  final String uid;
  final int number;
  final String body;
  final int replyToNumber;
  final List<int> replyFromNumbers;
  final DateTime createdAt;
}
