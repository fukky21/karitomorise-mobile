import 'package:flutter/material.dart';

class CurrentUser {
  CurrentUser({
    @required this.uid,
    @required this.email,
    @required this.createdAt,
    @required this.updatedAt,
  });

  final String uid;
  final String email;
  final DateTime createdAt;
  final DateTime updatedAt;
}
