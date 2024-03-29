import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../models/app_user.dart';
import '../../models/post.dart';
import '../../repositories/firebase_post_repository.dart';
import '../../repositories/firebase_user_repository.dart';
import '../../store.dart';

class HomeViewModel with ChangeNotifier {
  HomeViewModel({@required this.store});

  final Store store;
  final _userRepository = FirebaseUserRepository();
  final _postRepository = FirebasePostRepository();

  HomeScreenState _state = HomeScreenLoading();
  List<String> _postIdList = [];
  QueryDocumentSnapshot _lastVisible;
  bool _isFetching = false;

  HomeScreenState getState() {
    return _state;
  }

  Future<void> init() async {
    _state = HomeScreenLoading();
    notifyListeners();

    try {
      _postIdList = [];
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

        // 重複してgetUserしないようにする
        final addedUidByThisFetch = <String>[];

        for (final newPost in newPosts) {
          if (!_postIdList.contains(newPost.id)) {
            // まだ追加されていない場合は追加する
            _postIdList.add(newPost.id);
            store.addPost(post: newPost);

            // 今回のfetchで未追加(更新)のユーザーの場合はStoreに追加(更新)する
            if (newPost.uid != null &&
                !addedUidByThisFetch.contains(newPost.uid)) {
              if (newPost.isAnonymous) {
                store.addUser(
                  user: AppUser(
                    id: newPost.uid,
                    name: '名無しのハンター',
                    avatar: AppUserAvatar.unknown,
                  ),
                );
              } else {
                final user = await _userRepository.getUser(id: newPost.uid);
                store.addUser(user: user);
              }
              addedUidByThisFetch.add(newPost.uid);
            }
          } else {
            // すでに追加されている場合は、最後まで取得したと判定する
            _state = HomeScreenLoadSuccess(
              postIdList: _postIdList,
              isFetchabled: false,
            );
            notifyListeners();
            _isFetching = false; // fetchは終了したのでfalseにする
            return;
          }
        }
        _state = HomeScreenLoadSuccess(
          postIdList: _postIdList,
          isFetchabled: true,
        );
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
  HomeScreenLoadSuccess({
    @required this.postIdList,
    @required this.isFetchabled,
  });

  final List<String> postIdList;
  final bool isFetchabled;
}

class HomeScreenLoadFailure extends HomeScreenState {}
