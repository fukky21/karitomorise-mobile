import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../models/app_user.dart';
import '../../repositories/firebase_authentication_repository.dart';
import '../../repositories/firebase_user_repository.dart';
import '../../stores/signed_in_user_store.dart';
import '../../stores/users_store.dart';

class EditUserViewModel with ChangeNotifier {
  EditUserViewModel({
    @required this.usersStore,
    @required this.signedInUserStore,
  });

  final UsersStore usersStore;
  final SignedInUserStore signedInUserStore;
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

      // ユーザー情報を更新する
      final currentUser = _authRepository.getCurrentUser();
      final user = await _userRepository.getUser(id: currentUser.uid);
      signedInUserStore.setUser(user: user);
      usersStore.addUser(user: user);

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
