import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repositories/index.dart';
import 'sign_up_screen_event.dart';
import 'sign_up_screen_state.dart';

class SignUpScreenBloc extends Bloc<SignUpScreenEvent, SignUpScreenState> {
  SignUpScreenBloc({@required this.context}) : super(null) {
    _authRepository = context.read<FirebaseAuthenticationRepository>();
    _userRepository = context.read<FirebaseUserRepository>();
  }

  final BuildContext context;
  FirebaseAuthenticationRepository _authRepository;
  FirebaseUserRepository _userRepository;

  @override
  Stream<SignUpScreenState> mapEventToState(SignUpScreenEvent event) async* {
    if (event is SignUpOnPressed) {
      yield* _mapSignUpOnPressedToState(
        event.email,
        event.password,
        event.displayName,
      );
    }
  }

  Stream<SignUpScreenState> _mapSignUpOnPressedToState(
    String email,
    String password,
    String displayName,
  ) async* {
    yield SignUpInProgress();
    try {
      await _authRepository.signUpWithEmailAndPassword(email, password);
      await _userRepository.createUser(displayName);
      await _authRepository.signOut(); // アカウント作成後にサインイン状態にしない
      yield SignUpSuccess(email: email);
    } on FirebaseAuthException catch (e) {
      debugPrint(e.code);
      if (e.code == 'email-already-in-use') {
        yield SignUpFailure(type: SignUpFailureType.emailAlreadyInUse);
      } else if (e.code == 'invalid-email') {
        yield SignUpFailure(type: SignUpFailureType.invalidEmail);
      } else if (e.code == 'weak-password') {
        yield SignUpFailure(type: SignUpFailureType.weakPassword);
      } else {
        yield SignUpFailure(type: SignUpFailureType.other);
      }
    } on Exception catch (e) {
      debugPrint(e.toString());
      yield SignUpFailure(type: SignUpFailureType.other);
    }
  }
}
