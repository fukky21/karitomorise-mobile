import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../models/index.dart';
import '../repositories/index.dart';

class AuthenticationNotifier with ChangeNotifier {
  AuthenticationNotifier({
    @required this.authRepository,
    @required this.userRepository,
  }) {
    init();
  }

  final FirebaseAuthenticationRepository authRepository;
  final FirebaseUserRepository userRepository;
  AuthenticationState state;

  Future<void> init() async {
    state = AuthenticationInProgress();
    notifyListeners();

    try {
      final currentUser = authRepository.getCurrentUser();
      if (currentUser != null && currentUser.isAnonymous) {
        // 匿名アカウントでサインイン中の場合
        state = AuthenticationSuccess(
          currentUser: currentUser,
          user: AppUser(
            id: null,
            name: '名無しのハンター',
            avatar: AppUserAvatar.unknown,
          ),
        );
      } else if (currentUser != null && !currentUser.isAnonymous) {
        // 通常アカウントでサインイン中の場合
        final user = await userRepository.getUser(id: currentUser.uid);
        state = AuthenticationSuccess(currentUser: currentUser, user: user);
      } else {
        // サインインしていない場合
        await authRepository.signInAnonymously();
        final anonymousUser = authRepository.getCurrentUser();
        state = AuthenticationSuccess(
          currentUser: anonymousUser,
          user: AppUser(
            id: null,
            name: '名無しのハンター',
            avatar: AppUserAvatar.unknown,
          ),
        );
      }
      notifyListeners();
    } on Exception catch (e) {
      debugPrint(e.toString());
      state = AuthenticationFailure();
      notifyListeners();
    }
  }

  Future<void> updateUser() async {
    try {
      final currentUser = authRepository.getCurrentUser();
      final user = await userRepository.getUser(id: currentUser.uid);
      state = AuthenticationSuccess(currentUser: currentUser, user: user);
      notifyListeners();
    } on Exception catch (e) {
      debugPrint(e.toString());
      state = AuthenticationFailure();
      notifyListeners();
    }
  }

  Future<void> signIn() async {
    state = AuthenticationInProgress();
    notifyListeners();

    try {
      final currentUser = authRepository.getCurrentUser();
      final user = await userRepository.getUser(id: currentUser.uid);
      state = AuthenticationSuccess(currentUser: currentUser, user: user);
      notifyListeners();
    } on Exception catch (e) {
      debugPrint(e.toString());
      state = AuthenticationFailure();
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    state = AuthenticationInProgress();
    notifyListeners();

    try {
      await authRepository.signOut();
      await authRepository.signInAnonymously();
      final currentUser = authRepository.getCurrentUser();
      state = AuthenticationSuccess(
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
      state = AuthenticationFailure();
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
