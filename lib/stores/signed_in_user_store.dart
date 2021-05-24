import 'package:flutter/cupertino.dart';

import '../models/app_user.dart';

class SignedInUserStore with ChangeNotifier {
  AppUser _user = AppUser(
    id: null,
    name: '名無しのハンター',
    avatar: AppUserAvatar.unknown,
  );

  AppUser getUser() {
    return _user;
  }

  void setUser({@required AppUser user}) {
    _user = user;
    notifyListeners();
  }
}
