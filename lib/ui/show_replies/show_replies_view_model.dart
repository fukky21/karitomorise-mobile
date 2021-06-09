import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../models/app_user.dart';
import '../../models/post.dart';
import '../../repositories/firebase_post_repository.dart';
import '../../repositories/firebase_user_repository.dart';
import '../../store.dart';

class ShowRepliesViewModel with ChangeNotifier {
  ShowRepliesViewModel({@required this.sourcePost, @required this.store});

  final Post sourcePost;
  final Store store;
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

      // 重複してgetUserしないようにする
      final addedUid = <String>[];

      for (final post in posts) {
        // 今回のfetchで未追加(更新)のユーザーの場合はStoreに追加(更新)する
        if (post.uid != null && !addedUid.contains(post.uid)) {
          if (post.isAnonymous) {
            store.addUser(
              user: AppUser(
                id: post.uid,
                name: '名無しのハンター',
                avatar: AppUserAvatar.unknown,
              ),
            );
          } else {
            final user = await _userRepository.getUser(id: post.uid);
            store.addUser(user: user);
          }
          addedUid.add(post.uid);
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
