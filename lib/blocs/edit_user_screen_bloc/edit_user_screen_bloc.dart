import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/index.dart';
import '../../providers/index.dart';
import '../../repositories/index.dart';
import 'edit_user_screen_event.dart';
import 'edit_user_screen_state.dart';

class EditUserScreenBloc
    extends Bloc<EditUserScreenEvent, EditUserScreenState> {
  EditUserScreenBloc({@required this.context}) : super(null) {
    _authRepository = context.read<FirebaseAuthenticationRepository>();
    _userRepository = context.read<FirebaseUserRepository>();
    _usersProvider = context.read<UsersProvider>();
  }

  final BuildContext context;
  FirebaseAuthenticationRepository _authRepository;
  FirebaseUserRepository _userRepository;
  UsersProvider _usersProvider;

  @override
  Stream<EditUserScreenState> mapEventToState(
    EditUserScreenEvent event,
  ) async* {
    if (event is Initialized) {
      yield* _mapInitializedToState();
    }
    if (event is UpdateUserOnPressed) {
      yield* _mapUpdateUserOnPressedToState(event.user);
    }
  }

  Stream<EditUserScreenState> _mapInitializedToState() async* {
    yield InitializeInProgress();
    try {
      final currentUser = _authRepository.getCurrentUser();
      if (currentUser == null) {
        yield InitializeFailure();
      } else {
        final user = await _userRepository.getUser(currentUser.uid);
        yield InitializeSuccess(user: user);
      }
    } on Exception catch (e) {
      debugPrint(e.toString());
      yield InitializeFailure();
    }
  }

  Stream<EditUserScreenState> _mapUpdateUserOnPressedToState(
    AppUser user,
  ) async* {
    yield UpdateUserInProgress();
    try {
      final currentUser = _authRepository.getCurrentUser();
      if (currentUser == null) {
        yield UpdateUserFailure();
      } else {
        await _userRepository.updateUser(user);
        final updatedUser = await _userRepository.getUser(currentUser.uid);
        _usersProvider.add(updatedUser);
        yield UpdateUserSuccess();
      }
    } on Exception catch (e) {
      debugPrint(e.toString());
      yield UpdateUserFailure();
    }
  }
}
