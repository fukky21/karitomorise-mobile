import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../models/app_user.dart';
import '../../repositories/firebase_post_repository.dart';
import '../../repositories/firebase_user_repository.dart';
import '../../repositories/shared_preference_repository.dart';
import '../../store.dart';

class SearchResultViewModel with ChangeNotifier {
  SearchResultViewModel({@required this.keyword, @required this.store});

  final String keyword;
  final Store store;
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
      final _postIdList = <String>[];

      // 重複してgetUserしないようにする
      final addedUidByThisSearch = <String>[];

      for (final post in posts) {
        _postIdList.add(post.id);
        store.addPost(post: post);

        // 今回のfetchで未追加(更新)のユーザーの場合はStoreに追加(更新)する
        if (post.uid != null && !addedUidByThisSearch.contains(post.uid)) {
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
          addedUidByThisSearch.add(post.uid);
        }
      }

      _state = SearchResultScreenLoadSuccess(postIdList: _postIdList);
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
  SearchResultScreenLoadSuccess({@required this.postIdList});

  final List<String> postIdList;
}

class SearchResultScreenLoadFailure extends SearchResultScreenState {}
