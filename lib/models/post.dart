import 'package:flutter/material.dart';

class Post {
  Post({
    @required this.id,
    @required this.number,
    @required this.uid,
    @required this.body,
    @required this.replyToNumber,
    @required this.replyFromNumbers,
    @required this.createdAt,
  });

  final String id;
  final int number;
  final String uid;
  final String body;
  final int replyToNumber;
  final List<int> replyFromNumbers;
  final DateTime createdAt;
}
