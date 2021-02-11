import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repositories/index.dart';
import 'sign_up_screen_event.dart';
import 'sign_up_screen_state.dart';

class SignUpScreenBloc extends Bloc<SignUpScreenEvent, SignUpScreenState> {
  SignUpScreenBloc() : super(null);

  final _authRepository = FirebaseAuthenticationRepository();

  @override
  Stream<SignUpScreenState> mapEventToState(SignUpScreenEvent event) async* {
    if (event is SignUpOnPressed) {
      yield* _mapSignUpOnPressedToState(event.email, event.password);
    }
  }

  Stream<SignUpScreenState> _mapSignUpOnPressedToState(
    String email,
    String password,
  ) async* {
    yield SignUpInProgress();
    try {
      await _authRepository.signUpWithEmailAndPassword(email, password);
      yield SignUpSuccess(email: email);
    } on FirebaseAuthException catch (e) {
      debugPrint(e.code);
      if (e.code == 'email-already-in-use') {
        yield SignUpFailure(
          errorType: SignUpFailure.errorTypeEmailAlreadyInUse,
        );
      } else if (e.code == 'invalid-email') {
        yield SignUpFailure(
          errorType: SignUpFailure.errorTypeInvalidEmail,
        );
      } else if (e.code == 'weak-password') {
        yield SignUpFailure(
          errorType: SignUpFailure.errorTypeWeakPassword,
        );
      } else {
        yield SignUpFailure(
          errorType: SignUpFailure.errorTypeOther,
        );
      }
    } on Exception catch (e) {
      debugPrint(e.toString());
      yield SignUpFailure(
        errorType: SignUpFailure.errorTypeOther,
      );
    }
  }
}
