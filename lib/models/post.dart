import 'package:flutter/material.dart';

import 'app_user.dart';

class Post {
  Post({
    @required this.id,
    @required this.user,
    @required this.body,
    @required this.replyToNumber,
    @required this.replyFromNumbers,
    @required this.createdAt,
  });

  final int id;
  final AppUser user;
  final String body;
  final int replyToNumber;
  final List<int> replyFromNumbers;
  final DateTime createdAt;
}
