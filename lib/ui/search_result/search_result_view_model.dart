import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../models/post.dart';
import '../../repositories/firebase_post_repository.dart';

class SearchResultViewModel with ChangeNotifier {
  SearchResultViewModel({@required this.keyword});

  final String keyword;
  final _postRepository = FirebasePostRepository();

  SearchResultScreenState _state = SearchResultScreenLoading();

  SearchResultScreenState getState() {
    return _state;
  }

  Future<void> init() async {
    _state = SearchResultScreenLoading();
    notifyListeners();

    try {
      final posts = await _postRepository.getPostsByKeyword(keyword: keyword);
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
