import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/index.dart';
import '../../providers/index.dart';
import '../../repositories/index.dart';
import '../../widgets/components/index.dart';
import 'follow_user_button_event.dart';
import 'follow_user_button_state.dart';

class FollowUserButtonBloc
    extends Bloc<FollowUserButtonEvent, FollowUserButtonState> {
  FollowUserButtonBloc({@required this.context}) : super(null) {
    _userRepository = context.read<FirebaseUserRepository>();
    _usersProvider = context.read<UsersProvider>();
  }

  final BuildContext context;
  FirebaseUserRepository _userRepository;
  UsersProvider _usersProvider;

  @override
  Stream<FollowUserButtonState> mapEventToState(
    FollowUserButtonEvent event,
  ) async* {
    if (event is FollowUserOnPressed) {
      yield* _mapFollowUserOnPressedToState(event.user);
    }
    if (event is UnFollowUserOnPressed) {
      yield* _mapUnFollowUserOnPressedToState(event.user);
    }
  }

  Stream<FollowUserButtonState> _mapFollowUserOnPressedToState(
    AppUser user,
  ) async* {
    yield FollowUserButtonState(inProgress: true);
    try {
      await _userRepository.followUser(user.id);
      _usersProvider.add(user..isFollowed = true);
      showSnackBar(context, 'フォローしました');
      yield FollowUserButtonState(inProgress: false);
    } on Exception catch (e) {
      debugPrint(e.toString());
      showSnackBar(context, 'エラーが発生しました');
      yield FollowUserButtonState(inProgress: false);
    }
  }

  Stream<FollowUserButtonState> _mapUnFollowUserOnPressedToState(
    AppUser user,
  ) async* {
    yield FollowUserButtonState(inProgress: true);
    try {
      await _userRepository.unFollowUser(user.id);
      _usersProvider.add(user..isFollowed = false);
      showSnackBar(context, 'フォローを解除しました');
      yield FollowUserButtonState(inProgress: false);
    } on Exception catch (e) {
      debugPrint(e.toString());
      showSnackBar(context, 'エラーが発生しました');
      yield FollowUserButtonState(inProgress: false);
    }
  }
}
