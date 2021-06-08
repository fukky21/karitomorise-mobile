import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../models/post.dart';
import '../../repositories/firebase_post_repository.dart';
import '../../repositories/firebase_user_repository.dart';
import '../../stores/users_store.dart';

class HomeViewModel with ChangeNotifier {
  HomeViewModel({@required this.usersStore});

  final UsersStore usersStore;
  final _userRepository = FirebaseUserRepository();
  final _postRepository = FirebasePostRepository();

  HomeScreenState _state = HomeScreenLoading();
  List<Post> _posts = [];
  QueryDocumentSnapshot _lastVisible;
  bool _isFetching = false;

  HomeScreenState getState() {
    return _state;
  }

  Future<void> init() async {
    _state = HomeScreenLoading();
    notifyListeners();

    try {
      _posts = [];
      _lastVisible = null;
      await fetch();
    } on Exception catch (e) {
      debugPrint(e.toString());
      _state = HomeScreenLoadFailure();
      notifyListeners();
    }
  }

  Future<void> fetch() async {
    if (!_isFetching) {
      _isFetching = true;
      try {
        final result = await _postRepository.getNewPosts(
          lastVisible: _lastVisible,
        );
        final newPosts = result['posts'] as List<Post>;
        _lastVisible = result['lastVisible'] as QueryDocumentSnapshot;

        for (final newPost in newPosts) {
          if (_posts.where((post) => post.id == newPost.id).isEmpty) {
            // まだ追加されていない場合は追加する
            _posts.add(newPost);

            // usersStoreに未追加の場合は追加する
            if (!newPost.isAnonymous) {
              if (usersStore.getUser(uid: newPost.uid) == null) {
                final user = await _userRepository.getUser(id: newPost.uid);
                usersStore.addUser(user: user);
              }
            }
          } else {
            // すでに追加されている場合は、最後まで取得したと判定する
            _state = HomeScreenLoadSuccess(posts: _posts, isFetchabled: false);
            notifyListeners();
            _isFetching = false; // fetchは終了したのでfalseにする
            return;
          }
        }
        _state = HomeScreenLoadSuccess(posts: _posts, isFetchabled: true);
        notifyListeners();
      } on Exception catch (e) {
        debugPrint(e.toString());
        _state = HomeScreenLoadFailure();
        notifyListeners();
      }
      _isFetching = false;
    }
  }
}

abstract class HomeScreenState extends Equatable {
  @override
  List<Object> get props => const [];
}

class HomeScreenLoading extends HomeScreenState {}

class HomeScreenLoadSuccess extends HomeScreenState {
  HomeScreenLoadSuccess({@required this.posts, @required this.isFetchabled});

  final List<Post> posts;
  final bool isFetchabled;
}

class HomeScreenLoadFailure extends HomeScreenState {}
