import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../repositories/index.dart';
import 'sign_in_screen_event.dart';
import 'sign_in_screen_state.dart';

class SignInScreenBloc extends Bloc<SignInScreenEvent, SignInScreenState> {
  SignInScreenBloc() : super(null);

  final _authRepository = FirebaseAuthenticationRepository();

  @override
  Stream<SignInScreenState> mapEventToState(SignInScreenEvent event) async* {
    if (event is SignInWithEmailAndPasswordOnPressed) {
      yield* _mapSignInWithEmailAndPasswordOnPressedToState(
        event.email,
        event.password,
      );
    }
    if (event is SignInWithFacebookOnPressed) {
      yield* _mapSignInWithFacebookOnPressedToState();
    }
    if (event is SignInWithGoogleOnPressed) {
      yield* _mapSignInWithGoogleOnPressedToState();
    }
    if (event is SignInWithTwitterOnPressed) {
      yield* _mapSignInWithTwitterOnPressedToState();
    }
  }

  Stream<SignInScreenState> _mapSignInWithEmailAndPasswordOnPressedToState(
    String email,
    String password,
  ) async* {
    yield SignInInProgress();
    try {
      await _authRepository.signInWithEmailAndPassword(email, password);
      yield SignInSuccess();
    } on FirebaseAuthException catch (e) {
      debugPrint(e.code);
      if (e.code == 'invalid-email') {
        yield SignInFailure(
          errorType: SignInFailure.errorTypeInvalidEmail,
        );
      } else if (e.code == 'user-not-found') {
        yield SignInFailure(
          errorType: SignInFailure.errorTypeUserNotFound,
        );
      } else if (e.code == 'wrong-password') {
        yield SignInFailure(
          errorType: SignInFailure.errorTypeWrongPassword,
        );
      } else {
        yield SignInFailure(
          errorType: SignInFailure.errorTypeOther,
        );
      }
    } on Exception catch (e) {
      debugPrint(e.toString());
      yield SignInFailure(
        errorType: SignInFailure.errorTypeOther,
      );
    }
  }

  Stream<SignInScreenState> _mapSignInWithFacebookOnPressedToState() async* {}

  Stream<SignInScreenState> _mapSignInWithGoogleOnPressedToState() async* {}

  Stream<SignInScreenState> _mapSignInWithTwitterOnPressedToState() async* {}
}
