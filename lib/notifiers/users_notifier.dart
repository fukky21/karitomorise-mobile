import 'package:flutter/cupertino.dart';

import '../models/index.dart';
import '../repositories/index.dart';

class UsersNotifier with ChangeNotifier {
  UsersNotifier({@required this.userRepository}) {
    init();
  }

  final FirebaseUserRepository userRepository;
  List<AppUser> _users = [];

  AppUser get({@required String uid}) {
    final user = _users.firstWhere(
      (user) => user.id == uid,
      orElse: () => AppUser(
        id: null,
        name: '名無しのハンター',
        avatar: AppUserAvatar.unknown,
      ),
    );
    return user;
  }

  Future<void> add({@required String uid}) async {
    try {
      if (uid != null && _users.where((user) => user.id == uid).isEmpty) {
        // まだ追加されていなければ追加する
        final user = await userRepository.getUser(id: uid);
        if (user != null) {
          _users.add(user);
          notifyListeners();
        }
      }
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }

  void init() {
    _users = [];
    notifyListeners();
  }
}
