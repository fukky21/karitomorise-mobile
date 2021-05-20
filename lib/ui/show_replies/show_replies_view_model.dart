import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../models/post.dart';
import '../../repositories/firebase_post_repository.dart';

class ShowRepliesViewModel with ChangeNotifier {
  ShowRepliesViewModel({@required this.sourcePost});

  final Post sourcePost;
  final _postRepository = FirebasePostRepository();

  ShowRepliesScreenState _state = ShowRepliesScreenLoading();

  ShowRepliesScreenState getState() {
    return _state;
  }

  Future<void> init() async {
    _state = ShowRepliesScreenLoading();
    notifyListeners();

    try {
      final posts = await _postRepository.getReplies(
        replyFromIdList: sourcePost.replyFromIdList,
      );
      posts.insert(0, sourcePost); // 自分自身を配列の先頭に入れる
      _state = ShowRepliesScreenLoadSuccess(posts: posts);
      notifyListeners();
    } on Exception catch (e) {
      debugPrint(e.toString());
      _state = ShowRepliesScreenLoadFailure();
      notifyListeners();
    }
  }
}

abstract class ShowRepliesScreenState extends Equatable {
  @override
  List<Object> get props => const [];
}

class ShowRepliesScreenLoading extends ShowRepliesScreenState {}

class ShowRepliesScreenLoadSuccess extends ShowRepliesScreenState {
  ShowRepliesScreenLoadSuccess({@required this.posts});

  final List<Post> posts;
}

class ShowRepliesScreenLoadFailure extends ShowRepliesScreenState {}
