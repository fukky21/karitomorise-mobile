import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/app_user.dart';
import '../../repositories/firebase_authentication_repository.dart';
import '../../repositories/firebase_user_repository.dart';
import '../../stores/signed_in_user_store.dart';

class DeleteUserViewModel with ChangeNotifier {
  DeleteUserViewModel({@required this.signedInUserStore});

  final SignedInUserStore signedInUserStore;
  final _authRepository = FirebaseAuthenticationRepository();
  final _userRepository = FirebaseUserRepository();
  DeleteUserScreenState _state;

  DeleteUserScreenState getState() {
    return _state;
  }

  Future<void> deleteUser({@required String password}) async {
    _state = DeleteUserInProgress();
    notifyListeners();

    try {
      final currentUser = _authRepository.getCurrentUser();
      if (currentUser == null || currentUser.isAnonymous) {
        _state = DeleteUserFailure(type: DeleteUserFailureType.wrongPassword);
        notifyListeners();
      } else {
        await _authRepository.signInWithEmailAndPassword(
          email: currentUser.email,
          password: password,
        );
        await _userRepository.deleteUser();
        await _authRepository.deleteCurrentUser();
        await _authRepository.signInAnonymously();
        signedInUserStore.setUser(
          user: AppUser(
            id: null,
            name: '名無しのハンター',
            avatar: AppUserAvatar.unknown,
          ),
        );
        _state = DeleteUserSuccess();
        notifyListeners();
      }
    } on FirebaseAuthException catch (e) {
      debugPrint(e.code);
      if (e.code == 'wrong-password') {
        _state = DeleteUserFailure(type: DeleteUserFailureType.wrongPassword);
      } else {
        _state = DeleteUserFailure(type: DeleteUserFailureType.other);
      }
      notifyListeners();
    } on Exception catch (e) {
      debugPrint(e.toString());
      _state = DeleteUserFailure(type: DeleteUserFailureType.other);
      notifyListeners();
    }
  }
}

class DeleteUserScreenState extends Equatable {
  @override
  List<Object> get props => const [];
}

class DeleteUserInProgress extends DeleteUserScreenState {}

class DeleteUserSuccess extends DeleteUserScreenState {}

class DeleteUserFailure extends DeleteUserScreenState {
  DeleteUserFailure({@required this.type});

  final DeleteUserFailureType type;
}

enum DeleteUserFailureType { wrongPassword, other }
