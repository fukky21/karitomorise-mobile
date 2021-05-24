import 'package:flutter/cupertino.dart';

import '../models/app_user.dart';

class UsersStore with ChangeNotifier {
  final _users = <AppUser>[];

  AppUser getUser({@required String uid}) {
    return _users.firstWhere(
      (user) => user.id == uid,
      orElse: () => null,
    );
  }

  void addUser({@required AppUser user}) {
    if (user != null) {
      _users.add(user);
      notifyListeners();
    }
  }
}
