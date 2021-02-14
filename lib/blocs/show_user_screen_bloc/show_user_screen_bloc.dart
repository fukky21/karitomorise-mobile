import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../providers/index.dart';
import '../../repositories/index.dart';
import 'show_user_screen_event.dart';
import 'show_user_screen_state.dart';

class ShowUserScreenBloc
    extends Bloc<ShowUserScreenEvent, ShowUserScreenState> {
  ShowUserScreenBloc({@required this.context}) : super(null) {
    _userRepository = context.read<FirebaseUserRepository>();
    _usersProvider = context.read<UsersProvider>();
  }

  final BuildContext context;
  FirebaseUserRepository _userRepository;
  UsersProvider _usersProvider;

  @override
  Stream<ShowUserScreenState> mapEventToState(
    ShowUserScreenEvent event,
  ) async* {
    if (event is Initialized) {
      yield* _mapInitializedToState(event.uid);
    }
  }

  Stream<ShowUserScreenState> _mapInitializedToState(String uid) async* {
    yield InitializeInProgress();
    try {
      final user = await _userRepository.getUser(uid);
      if (user == null) {
        _usersProvider.remove(uid);
        yield InitializeFailure();
      } else {
        _usersProvider.add(user);
        yield InitializeSuccess();
      }
    } on Exception catch (e) {
      debugPrint(e.toString());
      yield InitializeFailure();
    }
  }
}
