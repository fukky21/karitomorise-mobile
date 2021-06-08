import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../repositories/firebase_authentication_repository.dart';
import '../../repositories/firebase_post_repository.dart';
import '../../repositories/firebase_user_repository.dart';

class CreatePostViewModel with ChangeNotifier {
  final _authRepository = FirebaseAuthenticationRepository();
  final _userRepository = FirebaseUserRepository();
  final _postRepository = FirebasePostRepository();

  CreatePostScreenState _state;

  CreatePostScreenState getState() {
    return _state;
  }

  Future<void> createPost({@required String body, int replyToNumber}) async {
    _state = CreatePostInProgress();
    notifyListeners();

    try {
      final currentUser = _authRepository.getCurrentUser();

      var isAvailable = true;
      if (!currentUser.isAnonymous) {
        isAvailable = await _userRepository.isAvailable(
          id: currentUser.uid,
        );
      }

      if (isAvailable) {
        await _postRepository.createPost(
          body: body,
          replyToNumber: replyToNumber,
        );
        _state = CreatePostSuccess();
        notifyListeners();
      } else {
        _state = CreatePostFailure(type: CreatePostFailureType.accountFrozen);
        notifyListeners();
      }
    } on Exception catch (e) {
      debugPrint(e.toString());
      _state = CreatePostFailure(type: CreatePostFailureType.other);
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

class CreatePostFailure extends CreatePostScreenState {
  CreatePostFailure({@required this.type});

  final CreatePostFailureType type;
}

enum CreatePostFailureType { accountFrozen, other }
