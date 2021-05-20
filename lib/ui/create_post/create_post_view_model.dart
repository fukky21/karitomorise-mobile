import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../repositories/firebase_post_repository.dart';

class CreatePostViewModel with ChangeNotifier {
  final _postRepository = FirebasePostRepository();

  CreatePostScreenState _state;

  CreatePostScreenState getState() {
    return _state;
  }

  Future<void> createPost({@required String body, int replyToId}) async {
    _state = CreatePostInProgress();
    notifyListeners();

    try {
      await _postRepository.createPost(body: body, replyToId: replyToId);
      _state = CreatePostSuccess();
      notifyListeners();
    } on Exception catch (e) {
      debugPrint(e.toString());
      _state = CreatePostFailure();
      notifyListeners();
    }
  }
}

abstract class CreatePostScreenState extends Equatable {
  @override
  List<Object> get props => const [];
}

class CreatePostInProgress extends CreatePostScreenState {}

class CreatePostSuccess extends CreatePostScreenState {}

class CreatePostFailure extends CreatePostScreenState {}
