import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../repositories/index.dart';

class SignUpScreenStateNotifier with ChangeNotifier {
  SignUpScreenStateNotifier({
    @required this.authRepository,
    @required this.userRepository,
  });

  SignUpScreenState state;
  final FirebaseAuthenticationRepository authRepository;
  final FirebaseUserRepository userRepository;

  Future<void> signUp({
    @required String email,
    @required String password,
    @required String name,
  }) async {
    state = SignUpInProgress();
    notifyListeners();

    try {
      await authRepository.signUpWithEmailAndPassword(
        email: email,
        password: password,
      );
      await userRepository.createUser(name: name);
      await authRepository.signOut(); // アカウント作成後にサインイン状態にしない
      state = SignUpSuccess(email: email);
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      debugPrint(e.code);
      if (e.code == 'email-already-in-use') {
        state = SignUpFailure(type: SignUpFailureType.emailAlreadyInUse);
      } else if (e.code == 'invalid-email') {
        state = SignUpFailure(type: SignUpFailureType.invalidEmail);
      } else if (e.code == 'weak-password') {
        state = SignUpFailure(type: SignUpFailureType.weakPassword);
      } else {
        state = SignUpFailure(type: SignUpFailureType.other);
      }
      notifyListeners();
    } on Exception catch (e) {
      debugPrint(e.toString());
      state = SignUpFailure(type: SignUpFailureType.other);
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
