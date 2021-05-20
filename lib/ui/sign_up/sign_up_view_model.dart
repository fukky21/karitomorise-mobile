import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../repositories/firebase_authentication_repository.dart';
import '../../repositories/firebase_user_repository.dart';

class SignUpViewModel with ChangeNotifier {
  final _authRepository = FirebaseAuthenticationRepository();
  final _userRepository = FirebaseUserRepository();

  SignUpScreenState _state;

  SignUpScreenState getState() {
    return _state;
  }

  Future<void> signUp({
    @required String email,
    @required String password,
    @required String name,
  }) async {
    _state = SignUpInProgress();
    notifyListeners();

    try {
      await _authRepository.signUpWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _userRepository.createUser(name: name);
      await _authRepository.signOut(); // アカウント作成後にサインイン状態にしない
      _state = SignUpSuccess(email: email);
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      debugPrint(e.code);
      if (e.code == 'email-already-in-use') {
        _state = SignUpFailure(type: SignUpFailureType.emailAlreadyInUse);
      } else if (e.code == 'invalid-email') {
        _state = SignUpFailure(type: SignUpFailureType.invalidEmail);
      } else if (e.code == 'weak-password') {
        _state = SignUpFailure(type: SignUpFailureType.weakPassword);
      } else {
        _state = SignUpFailure(type: SignUpFailureType.other);
      }
      notifyListeners();
    } on Exception catch (e) {
      debugPrint(e.toString());
      _state = SignUpFailure(type: SignUpFailureType.other);
      notifyListeners();
    }
  }
}

abstract class SignUpScreenState extends Equatable {
  @override
  List<Object> get props => const [];
}

class SignUpInProgress extends SignUpScreenState {}

class SignUpSuccess extends SignUpScreenState {
  SignUpSuccess({@required this.email});

  final String email;
}

class SignUpFailure extends SignUpScreenState {
  SignUpFailure({@required this.type});

  final SignUpFailureType type;
}

enum SignUpFailureType { emailAlreadyInUse, invalidEmail, weakPassword, other }
