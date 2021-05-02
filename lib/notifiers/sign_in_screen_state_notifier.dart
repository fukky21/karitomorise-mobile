import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../repositories/index.dart';

class SignInScreenStateNotifier with ChangeNotifier {
  SignInScreenStateNotifier({@required this.authRepository});

  final FirebaseAuthenticationRepository authRepository;
  SignInScreenState state;

  Future<void> signInWithEmailAndPassword({
    @required String email,
    @required String password,
  }) async {
    state = SignInInProgress();
    notifyListeners();

    try {
      await authRepository.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Screenの方でAuthenticationNotifier.init()を実行する

      state = SignInSuccess();
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      debugPrint(e.code);
      if (e.code == 'invalid-email') {
        state = SignInFailure(type: SignInFailureType.invalidEmail);
      } else if (e.code == 'user-not-found') {
        state = SignInFailure(type: SignInFailureType.userNotFound);
      } else if (e.code == 'wrong-password') {
        state = SignInFailure(type: SignInFailureType.wrongPassword);
      } else {
        state = SignInFailure(type: SignInFailureType.other);
      }
      notifyListeners();
    } on Exception catch (e) {
      debugPrint(e.toString());
      state = SignInFailure(type: SignInFailureType.other);
      notifyListeners();
    }
  }
}

abstract class SignInScreenState extends Equatable {
  @override
  List<Object> get props => const [];
}

class SignInInProgress extends SignInScreenState {}

class SignInSuccess extends SignInScreenState {}

class SignInFailure extends SignInScreenState {
  SignInFailure({@required this.type});

  final SignInFailureType type;
}

enum SignInFailureType { invalidEmail, userNotFound, wrongPassword, other }
