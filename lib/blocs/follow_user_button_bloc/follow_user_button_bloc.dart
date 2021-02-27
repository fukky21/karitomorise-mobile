import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    _followingProvider = context.read<FollowingProvider>();
  }

  final BuildContext context;
  FirebaseUserRepository _userRepository;
  UsersProvider _usersProvider;
  FollowingProvider _followingProvider;

  @override
  Stream<FollowUserButtonState> mapEventToState(
    FollowUserButtonEvent event,
  ) async* {
    if (event is FollowUserOnPressed) {
      yield* _mapFollowUserOnPressedToState(event.uid);
    }
    if (event is UnFollowUserOnPressed) {
      yield* _mapUnFollowUserOnPressedToState(event.uid);
    }
  }

  Stream<FollowUserButtonState> _mapFollowUserOnPressedToState(
    String uid,
  ) async* {
    yield FollowUserButtonState(inProgress: true);
    try {
      await _userRepository.followUser(uid);
      _usersProvider.follow(uid: uid);
      await _followingProvider.reload();
      showSnackBar(context, 'フォローしました');
      yield FollowUserButtonState(inProgress: false);
    } on Exception catch (e) {
      debugPrint(e.toString());
      showSnackBar(context, 'エラーが発生しました');
      yield FollowUserButtonState(inProgress: false);
    }
  }

  Stream<FollowUserButtonState> _mapUnFollowUserOnPressedToState(
    String uid,
  ) async* {
    yield FollowUserButtonState(inProgress: true);
    try {
      await _userRepository.unFollowUser(uid);
      _usersProvider.unFollow(uid: uid);
      await _followingProvider.reload();
      showSnackBar(context, 'フォローを解除しました');
      yield FollowUserButtonState(inProgress: false);
    } on Exception catch (e) {
      debugPrint(e.toString());
      showSnackBar(context, 'エラーが発生しました');
      yield FollowUserButtonState(inProgress: false);
    }
  }
}
