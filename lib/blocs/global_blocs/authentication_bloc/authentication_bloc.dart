import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../repositories/index.dart';
import 'authentication_event.dart';
import 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  AuthenticationBloc() : super(null);

  final _authRepository = FirebaseAuthenticationRepository();

  @override
  Stream<AuthenticationState> mapEventToState(
    AuthenticationEvent event,
  ) async* {
    if (event is AppStarted) {
      yield* _mapAppStartedToState();
    }
    if (event is SignedIn) {
      yield* _mapSignedInToState();
    }
    if (event is SignedOut) {
      yield* _mapSignedOutToState();
    }
  }

  Stream<AuthenticationState> _mapAppStartedToState() async* {
    yield AuthenticationInProgress();
    try {
      final currentUser = _authRepository.getCurrentUser();
      if (currentUser != null) {
        yield AuthenticationSuccess(currentUser: currentUser);
      } else {
        yield AuthenticationFailure();
      }
    } on Exception catch (e) {
      debugPrint(e.toString());
      yield AuthenticationFailure();
    }
  }

  Stream<AuthenticationState> _mapSignedInToState() async* {
    yield AuthenticationInProgress();
    final currentUser = _authRepository.getCurrentUser();
    yield AuthenticationSuccess(currentUser: currentUser);
  }

  Stream<AuthenticationState> _mapSignedOutToState() async* {
    yield AuthenticationInProgress();
    await _authRepository.signOut();
    yield AuthenticationFailure();
  }
}
