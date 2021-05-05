import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../models/index.dart';
import '../repositories/index.dart';

class SearchResultScreenStateNotifier with ChangeNotifier {
  SearchResultScreenStateNotifier({
    @required this.postRepository,
    @required this.keyword,
  }) {
    init();
  }

  final FirebasePostRepository postRepository;
  final String keyword;
  SearchResultScreenState state;

  Future<void> init() async {
    state = SearchResultScreenLoading();
    notifyListeners();

    try {
      final posts = await postRepository.getPostsByKeyword(keyword: keyword);
      state = SearchResultScreenLoadSuccess(posts: posts);
      notifyListeners();
    } on Exception catch (e) {
      debugPrint(e.toString());
      state = SearchResultScreenLoadFailure();
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
