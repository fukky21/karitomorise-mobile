import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../models/post.dart';
import '../../repositories/firebase_post_repository.dart';
import '../../repositories/firebase_user_repository.dart';
import '../../stores/users_store.dart';

class ShowRepliesViewModel with ChangeNotifier {
  ShowRepliesViewModel({@required this.sourcePost, @required this.usersStore});

  final Post sourcePost;
  final UsersStore usersStore;
  final _userRepository = FirebaseUserRepository();
  final _postRepository = FirebasePostRepository();

  ShowRepliesScreenState _state = ShowRepliesScreenLoading();

  ShowRepliesScreenState getState() {
    return _state;
  }

  Future<void> init() async {
    _state = ShowRepliesScreenLoading();
    notifyListeners();

    try {
      final posts = await _postRepository.getReplies(
        replyFromNumbers: sourcePost.replyFromNumbers,
      );
      posts.insert(0, sourcePost); // 自分自身を配列の先頭に入れる

      for (final post in posts) {
        // usersStoreに未追加の場合は追加する
        if (usersStore.getUser(uid: post.uid) == null) {
          final user = await _userRepository.getUser(id: post.uid);
          usersStore.addUser(user: user);
        }
      }

      _state = ShowRepliesScreenLoadSuccess(posts: posts);
      notifyListeners();
    } on Exception catch (e) {
      debugPrint(e.toString());
      _state = ShowRepliesScreenLoadFailure();
      notifyListeners();
    }
  }
}

abstract class ShowRepliesScreenState extends Equatable {
  @override
  List<Object> get props => const [];
}

class ShowRepliesScreenLoading extends ShowRepliesScreenState {}

class ShowRepliesScreenLoadSuccess extends ShowRepliesScreenState {
  ShowRepliesScreenLoadSuccess({@required this.posts});

  final List<Post> posts;
}

class ShowRepliesScreenLoadFailure extends ShowRepliesScreenState {}
