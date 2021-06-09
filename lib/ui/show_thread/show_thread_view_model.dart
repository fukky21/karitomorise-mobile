import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../models/app_user.dart';
import '../../models/post.dart';
import '../../repositories/firebase_post_repository.dart';
import '../../repositories/firebase_user_repository.dart';
import '../../store.dart';

class ShowThreadViewModel with ChangeNotifier {
  ShowThreadViewModel({@required this.sourcePost, @required this.store});

  final Post sourcePost;
  final Store store;
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
