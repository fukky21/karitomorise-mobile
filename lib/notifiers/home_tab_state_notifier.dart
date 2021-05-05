import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../models/index.dart';
import '../notifiers/index.dart';
import '../repositories/index.dart';

class HomeTabStateNotifier with ChangeNotifier {
  HomeTabStateNotifier({
    @required this.postRepository,
    @required this.usersNotifier,
  }) {
    init();
  }

  final FirebasePostRepository postRepository;
  final UsersNotifier usersNotifier;
  HomeTabState state = HomeTabLoading();
  List<Post> _posts = [];
  QueryDocumentSnapshot _lastVisible;
  bool _isFetching = false;

  Future<void> init() async {
    state = HomeTabLoading();
    notifyListeners();

    try {
      _posts = [];
      _lastVisible = null;

      final result = await postRepository.getNewPosts();
      final newPosts = result['posts'] as List<Post>;
      _lastVisible = result['last_visible'] as QueryDocumentSnapshot;

      for (final newPost in newPosts) {
        if (_posts.where((post) => post.id == newPost.id).isEmpty) {
          // まだ追加されていない場合は追加する
          _posts.add(newPost);
          await usersNotifier.add(uid: newPost.uid);
        } else {
          // すでに追加されている場合は、最後まで取得したと判定する
          state = HomeTabLoadSuccess(posts: _posts, isFetchabled: false);
          notifyListeners();
          return;
        }
      }
      state = HomeTabLoadSuccess(posts: _posts, isFetchabled: true);
      notifyListeners();
    } on Exception catch (e) {
      debugPrint(e.toString());
      state = HomeTabLoadFailure();
      notifyListeners();
    }
  }

  Future<void> fetch() async {
    if (!_isFetching) {
      _isFetching = true;
      try {
        final result = await postRepository.getNewPosts(
          lastVisible: _lastVisible,
        );
        final newPosts = result['posts'] as List<Post>;
        _lastVisible = result['last_visible'] as QueryDocumentSnapshot;

        for (final newPost in newPosts) {
          if (_posts.where((post) => post.id == newPost.id).isEmpty) {
            // まだ追加されていない場合は追加する
            _posts.add(newPost);
            await usersNotifier.add(uid: newPost.uid);
          } else {
            // すでに追加されている場合は、最後まで取得したと判定する
            state = HomeTabLoadSuccess(posts: _posts, isFetchabled: false);
            notifyListeners();
            return;
          }
        }
        state = HomeTabLoadSuccess(posts: _posts, isFetchabled: true);
        notifyListeners();
      } on Exception catch (e) {
        debugPrint(e.toString());
        state = HomeTabLoadFailure();
        notifyListeners();
      }
      _isFetching = false;
    }
  }
}

abstract class HomeTabState extends Equatable {
  @override
  List<Object> get props => const [];
}

class HomeTabLoading extends HomeTabState {}

class HomeTabLoadSuccess extends HomeTabState {
  HomeTabLoadSuccess({@required this.posts, @required this.isFetchabled});

  final List<Post> posts;
  final bool isFetchabled;
}

class HomeTabLoadFailure extends HomeTabState {}
