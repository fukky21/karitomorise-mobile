import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/index.dart';
import '../repositories/index.dart';

class UsersProvider with ChangeNotifier {
  UsersProvider({@required this.context}) {
    _authRepository = context.read<FirebaseAuthenticationRepository>();
    _userRepository = context.read<FirebaseUserRepository>();
    _init();
  }

  final BuildContext context;
  FirebaseAuthenticationRepository _authRepository;
  FirebaseUserRepository _userRepository;
  Map<String, AppUser> _userList;

  AppUser get({String uid}) {
    if (uid != null) {
      return _userList[uid];
    }
    return null;
  }

  void add({AppUser user}) {
    if (user != null && user.id != null) {
      _userList[user.id] = user;
      notifyListeners();
    }
  }

  void remove({String uid}) {
    if (uid != null) {
      _userList[uid] = null;
      notifyListeners();
    }
  }

  void follow({String uid}) {
    if (uid != null) {
      final user = _userList[uid];
      if (user != null) {
        user.followerCount++;
        add(user: user);
      }
    }
  }

  void unFollow({String uid}) {
    if (uid != null) {
      final user = _userList[uid];
      if (user != null && user.followerCount != 0) {
        user.followerCount--;
        add(user: user);
      }
    }
  }

  Future<void> _init() async {
    _userList = {};
    final currentUser = _authRepository.getCurrentUser();
    if (currentUser != null) {
      final user = await _userRepository.getUser(currentUser.uid);
      add(user: user);
    }
    notifyListeners();
  }
}
