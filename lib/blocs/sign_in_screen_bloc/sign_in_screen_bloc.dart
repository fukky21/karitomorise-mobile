import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../providers/index.dart';
import '../../repositories/index.dart';
import 'sign_in_screen_event.dart';
import 'sign_in_screen_state.dart';

class SignInScreenBloc extends Bloc<SignInScreenEvent, SignInScreenState> {
  SignInScreenBloc({@required this.context}) : super(null) {
    _authRepository = context.read<FirebaseAuthenticationRepository>();
    _userRepository = context.read<FirebaseUserRepository>();
    _usersProvider = context.read<UsersProvider>();
  }

  final BuildContext context;
  FirebaseAuthenticationRepository _authRepository;
  FirebaseUserRepository _userRepository;
  UsersProvider _usersProvider;

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
      final currentUser = _authRepository.getCurrentUser();
      final user = await _userRepository.getUser(currentUser.uid);
      _usersProvider.add(user);
      yield SignInSuccess();
    } on FirebaseAuthException catch (e) {
      debugPrint(e.code);
      if (e.code == 'invalid-email') {
        yield SignInFailure(type: SignInFailureType.invalidEmail);
      } else if (e.code == 'user-not-found') {
        yield SignInFailure(type: SignInFailureType.userNotFound);
      } else if (e.code == 'wrong-password') {
        yield SignInFailure(type: SignInFailureType.wrongPassword);
      } else {
        yield SignInFailure(type: SignInFailureType.other);
      }
    } on Exception catch (e) {
      debugPrint(e.toString());
      yield SignInFailure(type: SignInFailureType.other);
    }
  }

  Stream<SignInScreenState> _mapSignInWithFacebookOnPressedToState() async* {}

  Stream<SignInScreenState> _mapSignInWithGoogleOnPressedToState() async* {}

  Stream<SignInScreenState> _mapSignInWithTwitterOnPressedToState() async* {}
}
