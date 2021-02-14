import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../repositories/index.dart';
import 'show_user_screen_event.dart';
import 'show_user_screen_state.dart';

class ShowUserScreenBloc
    extends Bloc<ShowUserScreenEvent, ShowUserScreenState> {
  ShowUserScreenBloc() : super(null);

  final _authRepository = FirebaseAuthenticationRepository();
  final _userRepository = FirebaseUserRepository();

  @override
  Stream<ShowUserScreenState> mapEventToState(
    ShowUserScreenEvent event,
  ) async* {
    if (event is Initialized) {
      yield* _mapInitializedToState(event.uid);
    }
  }

  Stream<ShowUserScreenState> _mapInitializedToState(String uid) async* {
    yield Loading();
    try {
      final user = await _userRepository.getUser(uid);
      if (user == null) {
        yield LoadFailure(errorType: LoadFailure.errorTypeUserAlreadyDeleted);
      } else {
        final currentUser = _authRepository.getCurrentUser();
        if (currentUser != null && currentUser.uid == uid) {
          yield LoadSuccess(user: user, editable: true);
        } else {
          yield LoadSuccess(user: user, editable: false);
        }
      }
    } on Exception catch (e) {
      debugPrint(e.toString());
      LoadFailure(errorType: LoadFailure.errorTypeOther);
    }
  }
}
