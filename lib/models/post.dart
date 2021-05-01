import 'package:flutter/material.dart';

import 'app_user.dart';

class Post {
  Post({
    @required this.id,
    @required this.user,
    @required this.body,
    @required this.anchorId,
    @required this.replyIdList,
    @required this.createdAt,
  });

  final int id;
  final AppUser user;
  final String body;
  final int anchorId;
  final List<int> replyIdList;
  final DateTime createdAt;
}
