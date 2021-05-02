import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../repositories/index.dart';

class CreatePostScreenStateNotifier with ChangeNotifier {
  CreatePostScreenStateNotifier({@required this.postRepository});

  CreatePostScreenState state;
  final FirebasePostRepository postRepository;

  Future<void> createPost({@required String body, int replyToNumber}) async {
    state = CreatePostInProgress();
    notifyListeners();

    try {
      await postRepository.create(body: body, replyToNumber: replyToNumber);
      state = CreatePostSuccess();
      notifyListeners();
    } on Exception catch (e) {
      debugPrint(e.toString());
      state = CreatePostFailure();
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
