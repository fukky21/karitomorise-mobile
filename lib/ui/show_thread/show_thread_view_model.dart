import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../models/post.dart';
import '../../repositories/firebase_post_repository.dart';

class ShowThreadViewModel with ChangeNotifier {
  ShowThreadViewModel({@required this.sourcePost});

  final Post sourcePost;
  final _postRepository = FirebasePostRepository();

  ShowThreadScreenState _state = ShowThreadScreenLoading();

  ShowThreadScreenState getState() {
    return _state;
  }

  Future<void> init() async {
    _state = ShowThreadScreenLoading();
    notifyListeners();

    try {
      final posts = await _postRepository.getThread(
        replyToId: sourcePost.replyToId,
      );
      posts.insert(0, sourcePost); // 自分自身を配列の先頭に入れる
      _state = ShowThreadScreenLoadSuccess(posts: posts);
      notifyListeners();
    } on Exception catch (e) {
      debugPrint(e.toString());
      _state = ShowThreadScreenLoadFailure();
      notifyListeners();
    }
  }
}

abstract class ShowThreadScreenState extends Equatable {
  @override
  List<Object> get props => const [];
}

class ShowThreadScreenLoading extends ShowThreadScreenState {}

class ShowThreadScreenLoadSuccess extends ShowThreadScreenState {
  ShowThreadScreenLoadSuccess({@required this.posts});

  final List<Post> posts;
}

class ShowThreadScreenLoadFailure extends ShowThreadScreenState {}
