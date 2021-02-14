import 'package:flutter/material.dart';

import '../models/index.dart';
import '../repositories/index.dart';

class UsersProvider with ChangeNotifier {
  UsersProvider({
    @required FirebaseAuthenticationRepository authRepository,
    @required FirebaseUserRepository userRepository,
  }) {
    _authRepository = authRepository;
    _userRepository = userRepository;
    _init();
  }

  FirebaseAuthenticationRepository _authRepository;
  FirebaseUserRepository _userRepository;
  Map<String, AppUser> _userList;

  AppUser get(String uid) {
    if (uid != null) {
      return _userList[uid];
    }
    return null;
  }

  void add(AppUser user) {
    if (user != null) {
      _userList[user.id] = user;
    }
    notifyListeners();
  }

  void remove(String uid) {
    _userList[uid] = null;
    notifyListeners();
  }

  Future<void> _init() async {
    _userList = {};
    final currentUser = _authRepository.getCurrentUser();
    if (currentUser != null) {
      final user = await _userRepository.getUser(currentUser.uid);
      add(user);
    }
    notifyListeners();
  }
}
