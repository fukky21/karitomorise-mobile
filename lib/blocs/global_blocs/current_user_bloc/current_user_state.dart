import 'package:flutter/material.dart';

import '../../../models/index.dart';

class CurrentUserState {
  CurrentUserState({@required this.user, @required this.likedEvents});

  final AppUser user;
  final List<String> likedEvents;
}
