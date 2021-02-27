import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../providers/index.dart';
import '../../repositories/index.dart';
import 'authentication_event.dart';
import 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  AuthenticationBloc({@required this.context}) : super(null) {
    _authRepository = context.read<FirebaseAuthenticationRepository>();
    _userRepository = context.read<FirebaseUserRepository>();
    _usersProvider = context.read<UsersProvider>();
    _followingProvider = context.read<FollowingProvider>();
  }

  final BuildContext context;
  FirebaseAuthenticationRepository _authRepository;
  FirebaseUserRepository _userRepository;
  UsersProvider _usersProvider;
  FollowingProvider _followingProvider;

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
      final currentUser = await _authRepository.getCurrentUser();
      if (currentUser != null) {
        yield AuthenticationSuccess(currentUser: currentUser);
      } else {
        yield AuthenticationFailure();
      }
    } on Exception catch (_) {
      yield AuthenticationFailure();
    }
  }

  Stream<AuthenticationState> _mapSignedInToState() async* {
    yield AuthenticationInProgress();
    final currentUser = await _authRepository.getCurrentUser();
    final user = await _userRepository.getUser(currentUser.uid);
    _usersProvider.add(user: user);
    await _followingProvider.reload();
    yield AuthenticationSuccess(currentUser: currentUser);
  }

  Stream<AuthenticationState> _mapSignedOutToState() async* {
    yield AuthenticationInProgress();
    await _authRepository.signOut();
    await _followingProvider.reload();
    yield AuthenticationFailure();
  }
}
