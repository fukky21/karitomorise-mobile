import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../models/post.dart';
import '../../repositories/firebase_post_repository.dart';
import '../../repositories/firebase_user_repository.dart';
import '../../stores/users_store.dart';

class ShowThreadViewModel with ChangeNotifier {
  ShowThreadViewModel({@required this.sourcePost, @required this.usersStore});

  final Post sourcePost;
  final UsersStore usersStore;
  final _userRepository = FirebaseUserRepository();
  final _postRepository = FirebasePostRepository();

  ShowThreadScreenState _state = ShowThreadScreenLoading();

  ShowThreadScreenState getState() {
    return _state;
  }

  Future<void> init() async {
    _state = ShowThreadScreenLoading();
    notifyListeners();

    try {
      final posts = await _postRepository.getThread(
        replyToNumber: sourcePost.replyToNumber,
      );
      posts.insert(0, sourcePost); // 自分自身を配列の先頭に入れる

      for (final post in posts) {
        // usersStoreに未追加の場合は追加する
        if (!post.isAnonymous) {
          if (usersStore.getUser(uid: post.uid) == null) {
            final user = await _userRepository.getUser(id: post.uid);
            usersStore.addUser(user: user);
          }
        }
      }

      _state = ShowThreadScreenLoadSuccess(posts: posts);
      notifyListeners();
    } on Exception catch (e) {
      debugPrint(e.toString());
      _state = ShowThreadScreenLoadFailure();
      notifyListeners();
    }
  }
}

abstract class ShowThreadScreenState extends Equatable {
  @override
  List<Object> get props => const [];
}

class ShowThreadScreenLoading extends ShowThreadScreenState {}

class ShowThreadScreenLoadSuccess extends ShowThreadScreenState {
  ShowThreadScreenLoadSuccess({@required this.posts});

  final List<Post> posts;
}

class ShowThreadScreenLoadFailure extends ShowThreadScreenState {}
