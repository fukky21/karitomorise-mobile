import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'models/app_user.dart';
import 'models/current_user.dart';
import 'models/post.dart';
import 'repositories/firebase_user_repository.dart';

class Store with ChangeNotifier {
  Store() {
    FirebaseAuth.instance.userChanges().listen((user) async {
      debugPrint('userChanges: $user');
      if (user != null) {
        currentUser = CurrentUser(
          uid: user.uid,
          email: user.email,
          isAnonymous: user.isAnonymous,
          createdAt: user.metadata.creationTime,
          updatedAt: user.metadata.lastSignInTime,
        );
        if (user.isAnonymous) {
          addUser(
            user: AppUser(
              id: user.uid,
              name: '名無しのハンター',
              avatar: AppUserAvatar.unknown,
            ),
          );
        } else {
          try {
            final newUser = await userRepository.getUser(id: user.uid);
            if (newUser == null) {
              // サインイン中のユーザーのドキュメントが存在しない場合
              debugPrint('User is not found. ( uid : ${user.uid} )');
            }
            addUser(user: newUser);
          } on Exception catch (e) {
            debugPrint(e.toString());
          }
        }
        notifyListeners();
      }
    });
  }

  final userRepository = FirebaseUserRepository();
  CurrentUser currentUser;
  Map<String, AppUser> users = {};
  Map<String, Post> posts = {};

  void addUser({@required AppUser user}) {
    if (user != null && user.id != null) {
      users[user.id] = user;
      notifyListeners();
    } else {
      debugPrint('addUser failed.');
    }
  }

  void addPost({@required Post post}) {
    if (post != null && post.id != null) {
      posts[post.id] = post;
      notifyListeners();
    } else {
      debugPrint('addPost failed.');
    }
  }
}
