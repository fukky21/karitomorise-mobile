import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../models/index.dart';

class HomeTabStateNotifier with ChangeNotifier {
  HomeTabStateNotifier() {
    init();
  }

  HomeTabState state = HomeTabLoading();
  List<Post> _posts = [];
  bool _isFetching = false;

  Future<void> init() async {
    state = HomeTabLoading();
    notifyListeners();

    try {
      _posts = [];

      // TODO(fukky21): 初期化処理を実装する
      await Future<void>.delayed(const Duration(seconds: 3));
      for (var i = 0; i < 10; i++) {
        _posts.add(
          Post(
            id: 5000,
            user: AppUser(
              id: null,
              name: '名無しのハンター',
              avatar: AppUserAvatar.agnaktor,
            ),
            replyToNumber: 4900,
            body: '本文です本文です本文です本文です本文です本文です本文です本文です',
            replyFromNumbers: [5001, 5002 - i],
            createdAt: DateTime.now(),
          ),
        );
      }

      state = HomeTabLoadSuccess(posts: _posts);
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
        // TODO(fukky21): 追加で投稿を取得する処理を実装する
        await Future<void>.delayed(const Duration(seconds: 3));
        for (var i = 0; i < 10; i++) {
          _posts.add(
            Post(
              id: 5000,
              user: AppUser(
                id: null,
                name: '名無しのハンター',
                avatar: AppUserAvatar.agnaktor,
              ),
              replyToNumber: 4900,
              body: 'これは追加分です',
              replyFromNumbers: [5001, 5002],
              createdAt: DateTime.now(),
            ),
          );
        }
        state = HomeTabLoadSuccess(posts: _posts);
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
  HomeTabLoadSuccess({@required this.posts});

  final List<Post> posts;
}

class HomeTabLoadFailure extends HomeTabState {}
