import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../models/post.dart';
import '../../repositories/firebase_post_repository.dart';
import '../../repositories/firebase_user_repository.dart';
import '../../repositories/shared_preference_repository.dart';
import '../../stores/users_store.dart';

class SearchResultViewModel with ChangeNotifier {
  SearchResultViewModel({@required this.keyword, @required this.usersStore});

  final String keyword;
  final UsersStore usersStore;
  final _userRepository = FirebaseUserRepository();
  final _postRepository = FirebasePostRepository();
  final _prefRepository = SharedPreferenceRepository();

  SearchResultScreenState _state = SearchResultScreenLoading();

  SearchResultScreenState getState() {
    return _state;
  }

  Future<void> init() async {
    _state = SearchResultScreenLoading();
    notifyListeners();

    try {
      // 検索履歴に保存する
      await _prefRepository.addSearchKeyword(keyword: keyword);

      final posts = await _postRepository.getPostsByKeyword(keyword: keyword);

      for (final post in posts) {
        // usersStoreに未追加の場合は追加する
        if (usersStore.getUser(uid: post.uid) == null) {
          final user = await _userRepository.getUser(id: post.uid);
          usersStore.addUser(user: user);
        }
      }

      _state = SearchResultScreenLoadSuccess(posts: posts);
      notifyListeners();
    } on Exception catch (e) {
      debugPrint(e.toString());
      _state = SearchResultScreenLoadFailure();
      notifyListeners();
    }
  }
}

abstract class SearchResultScreenState extends Equatable {
  @override
  List<Object> get props => const [];
}

class SearchResultScreenLoading extends SearchResultScreenState {}

class SearchResultScreenLoadSuccess extends SearchResultScreenState {
  SearchResultScreenLoadSuccess({@required this.posts});

  final List<Post> posts;
}

class SearchResultScreenLoadFailure extends SearchResultScreenState {}
