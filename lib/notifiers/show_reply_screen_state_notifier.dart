import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../models/index.dart';
import '../repositories/index.dart';

class ShowReplyScreenStateNotifier with ChangeNotifier {
  ShowReplyScreenStateNotifier({
    @required this.postRepository,
    @required this.sourcePost,
  }) {
    init();
  }

  final FirebasePostRepository postRepository;
  final Post sourcePost;
  ShowReplyScreenState state = ShowReplyScreenLoading();

  Future<void> init() async {
    state = ShowReplyScreenLoading();
    notifyListeners();

    try {
      final posts = await postRepository.getReplies(
        replyFromIdList: sourcePost.replyFromIdList,
      );
      posts.insert(0, sourcePost); // 自分自身を配列の先頭に入れる
      state = ShowReplyScreenLoadSuccess(posts: posts);
      notifyListeners();
    } on Exception catch (e) {
      debugPrint(e.toString());
      state = ShowReplyScreenLoadFailure();
      notifyListeners();
    }
  }
}

abstract class ShowReplyScreenState extends Equatable {
  @override
  List<Object> get props => const [];
}

class ShowReplyScreenLoading extends ShowReplyScreenState {}

class ShowReplyScreenLoadSuccess extends ShowReplyScreenState {
  ShowReplyScreenLoadSuccess({@required this.posts});

  final List<Post> posts;
}

class ShowReplyScreenLoadFailure extends ShowReplyScreenState {}
