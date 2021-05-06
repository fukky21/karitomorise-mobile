import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../models/index.dart';
import '../repositories/index.dart';

class ThreadScreenStateNotifier with ChangeNotifier {
  ThreadScreenStateNotifier({
    @required this.postRepository,
    @required this.sourcePost,
  }) {
    init();
  }

  final FirebasePostRepository postRepository;
  final Post sourcePost;
  ThreadScreenState state = ThreadScreenLoading();

  Future<void> init() async {
    state = ThreadScreenLoading();
    notifyListeners();

    try {
      final posts = await postRepository.getThread(
        replyToId: sourcePost.replyToId,
      );
      posts.insert(0, sourcePost); // 自分自身を配列の先頭に入れる
      state = ThreadScreenLoadSuccess(posts: posts);
      notifyListeners();
    } on Exception catch (e) {
      debugPrint(e.toString());
      state = ThreadScreenLoadFailure();
      notifyListeners();
    }
  }
}

abstract class ThreadScreenState extends Equatable {
  @override
  List<Object> get props => const [];
}

class ThreadScreenLoading extends ThreadScreenState {}

class ThreadScreenLoadSuccess extends ThreadScreenState {
  ThreadScreenLoadSuccess({@required this.posts});

  final List<Post> posts;
}

class ThreadScreenLoadFailure extends ThreadScreenState {}
