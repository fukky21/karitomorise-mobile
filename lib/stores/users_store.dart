import 'package:flutter/cupertino.dart';

import '../models/app_user.dart';
import '../repositories/firebase_user_repository.dart';

class UsersStore with ChangeNotifier {
  final _userRepository = FirebaseUserRepository();

  final _users = <AppUser>[];

  AppUser getUser({@required String uid}) {
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
    if (uid == null || _users.where((user) => user.id == uid).isNotEmpty) {
      // すでにユーザーが追加されている場合は何もしない
      return;
    }
    try {
      final user = await _userRepository.getUser(id: uid);
      _users.add(user);
      notifyListeners();
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }
}
