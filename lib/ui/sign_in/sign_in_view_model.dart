import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../repositories/firebase_authentication_repository.dart';
import '../../stores/authentication_store.dart';

class SignInViewModel with ChangeNotifier {
  SignInViewModel({@required this.authStore});

  final AuthenticationStore authStore;
  final _authRepository = FirebaseAuthenticationRepository();

  SignInScreenState _state;

  SignInScreenState getState() {
    return _state;
  }

  Future<void> signInWithEmailAndPassword({
    @required String email,
    @required String password,
  }) async {
    _state = SignInInProgress();
    notifyListeners();

    try {
      await _authRepository.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await authStore.signedIn();
      _state = SignInSuccess();
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      debugPrint(e.code);
      if (e.code == 'invalid-email') {
        _state = SignInFailure(type: SignInFailureType.invalidEmail);
      } else if (e.code == 'user-not-found') {
        _state = SignInFailure(type: SignInFailureType.userNotFound);
      } else if (e.code == 'wrong-password') {
        _state = SignInFailure(type: SignInFailureType.wrongPassword);
      } else {
        _state = SignInFailure(type: SignInFailureType.other);
      }
      notifyListeners();
    } on Exception catch (e) {
      debugPrint(e.toString());
      _state = SignInFailure(type: SignInFailureType.other);
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
