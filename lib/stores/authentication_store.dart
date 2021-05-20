import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../models/current_user.dart';
import '../repositories/firebase_authentication_repository.dart';
import '../repositories/firebase_user_repository.dart';

class AuthenticationStore with ChangeNotifier {
  final _authRepository = FirebaseAuthenticationRepository();
  final _userRepository = FirebaseUserRepository();

  AuthenticationState _state;

  AuthenticationState getState() {
    return _state;
  }

  Future<void> init() async {
    _state = AuthenticationInProgress();
    notifyListeners();

    try {
      final currentUser = _authRepository.getCurrentUser();
      if (currentUser != null) {
        if (currentUser.isAnonymous) {
          _state = AuthenticationSuccess(
            currentUser: currentUser,
            user: AppUser(
              id: null,
              name: '名無しのハンター',
              avatar: AppUserAvatar.unknown,
            ),
          );
        } else {
          final user = await _userRepository.getUser(id: currentUser.uid);
          _state = AuthenticationSuccess(currentUser: currentUser, user: user);
        }
      } else {
        _state = AuthenticationFailure();
      }
      notifyListeners();
    } on Exception catch (e) {
      debugPrint(e.toString());
      _state = AuthenticationFailure();
      notifyListeners();
    }
  }

  Future<void> signedIn() async {
    _state = AuthenticationInProgress();
    notifyListeners();

    try {
      final currentUser = _authRepository.getCurrentUser();
      final user = await _userRepository.getUser(id: currentUser.uid);
      _state = AuthenticationSuccess(currentUser: currentUser, user: user);
      notifyListeners();
    } on Exception catch (e) {
      debugPrint(e.toString());
      _state = AuthenticationFailure();
      notifyListeners();
    }
  }

  Future<void> signedOut() async {
    _state = AuthenticationInProgress();
    notifyListeners();

    try {
      // 一度サインアウトして匿名でサインインし直す
      await _authRepository.signOut();
      await _authRepository.signInAnonymously();
      final currentUser = _authRepository.getCurrentUser();
      _state = AuthenticationSuccess(
        currentUser: currentUser,
        user: AppUser(
          id: null,
          name: '名無しのハンター',
          avatar: AppUserAvatar.unknown,
        ),
      );
      notifyListeners();
    } on Exception catch (e) {
      debugPrint(e.toString());
      _state = AuthenticationFailure();
      notifyListeners();
    }
  }
}

class AuthenticationState extends Equatable {
  @override
  List<Object> get props => const [];
}

class AuthenticationInProgress extends AuthenticationState {}

class AuthenticationSuccess extends AuthenticationState {
  AuthenticationSuccess({@required this.currentUser, @required this.user});

  final CurrentUser currentUser;
  final AppUser user;
}

class AuthenticationFailure extends AuthenticationState {}
