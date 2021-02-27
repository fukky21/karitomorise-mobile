import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repositories/index.dart';
import '../authentication_bloc/index.dart';
import 'sign_in_screen_event.dart';
import 'sign_in_screen_state.dart';

class SignInScreenBloc extends Bloc<SignInScreenEvent, SignInScreenState> {
  SignInScreenBloc({@required this.context}) : super(null) {
    _authBloc = context.read<AuthenticationBloc>();
    _authRepository = context.read<FirebaseAuthenticationRepository>();
  }

  final BuildContext context;
  AuthenticationBloc _authBloc;
  FirebaseAuthenticationRepository _authRepository;

  @override
  Stream<SignInScreenState> mapEventToState(SignInScreenEvent event) async* {
    if (event is SignInOnPressed) {
      yield* _mapSignInOnPressedToState(event.email, event.password);
    }
  }

  Stream<SignInScreenState> _mapSignInOnPressedToState(
    String email,
    String password,
  ) async* {
    yield SignInInProgress();
    try {
      await _authRepository.signInWithEmailAndPassword(email, password);
      _authBloc.add(SignedIn());
      final currentUser = _authRepository.getCurrentUser();
      yield SignInSuccess(uid: currentUser.uid);
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
}
