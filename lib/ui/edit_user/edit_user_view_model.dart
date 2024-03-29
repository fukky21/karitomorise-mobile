import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../models/app_user.dart';
import '../../repositories/firebase_authentication_repository.dart';
import '../../repositories/firebase_user_repository.dart';

class EditUserViewModel with ChangeNotifier {
  final _authRepository = FirebaseAuthenticationRepository();
  final _userRepository = FirebaseUserRepository();

  EditUserScreenState _state;

  EditUserScreenState getState() {
    return _state;
  }

  Future<void> updateUser({
    @required String name,
    @required AppUserAvatar avatar,
  }) async {
    _state = UpdateUserInProgress();
    notifyListeners();

    try {
      await _userRepository.updateUser(name: name, avatar: avatar);
      await _authRepository.updateDisplayName(displayName: name);

      _state = UpdateUserSuccess();
      notifyListeners();
    } on Exception catch (e) {
      debugPrint(e.toString());
      _state = UpdateUserFailure();
      notifyListeners();
    }
  }
}

abstract class EditUserScreenState extends Equatable {
  @override
  List<Object> get props => const [];
}

class UpdateUserInProgress extends EditUserScreenState {}

class UpdateUserSuccess extends EditUserScreenState {}

class UpdateUserFailure extends EditUserScreenState {}
