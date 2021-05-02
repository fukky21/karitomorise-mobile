import 'package:flutter/material.dart';

class CurrentUser {
  CurrentUser({
    @required this.uid,
    @required this.email,
    @required this.isAnonymous,
    @required this.createdAt,
    @required this.updatedAt,
  });

  final String uid;
  final String email;
  final bool isAnonymous;
  final DateTime createdAt;
  final DateTime updatedAt;
}
