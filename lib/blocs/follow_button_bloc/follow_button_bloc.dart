import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../providers/index.dart';
import '../../repositories/index.dart';
import '../../widgets/components/index.dart';
import 'follow_button_event.dart';
import 'follow_button_state.dart';

class FollowButtonBloc extends Bloc<FollowButtonEvent, FollowButtonState> {
  FollowButtonBloc({@required this.context}) : super(null) {
    _userRepository = context.read<FirebaseUserRepository>();
    _usersProvider = context.read<UsersProvider>();
    _followingProvider = context.read<FollowingProvider>();
  }

  final BuildContext context;
  FirebaseUserRepository _userRepository;
  UsersProvider _usersProvider;
  FollowingProvider _followingProvider;

  @override
  Stream<FollowButtonState> mapEventToState(FollowButtonEvent event) async* {
    if (event is FollowUserOnPressed) {
      yield* _mapFollowUserOnPressedToState(event.uid);
    }
    if (event is UnFollowUserOnPressed) {
      yield* _mapUnFollowUserOnPressedToState(event.uid);
    }
  }

  Stream<FollowButtonState> _mapFollowUserOnPressedToState(
    String uid,
  ) async* {
    yield FollowButtonState(inProgress: true);
    try {
      await _userRepository.followUser(uid);
      _usersProvider.follow(uid: uid); // フォロワー数を+1する
      await _followingProvider.reload();
      showSnackBar(context, 'フォローしました');
      yield FollowButtonState(inProgress: false);
    } on Exception catch (e) {
      debugPrint(e.toString());
      showSnackBar(context, 'エラーが発生しました');
      yield FollowButtonState(inProgress: false);
    }
  }

  Stream<FollowButtonState> _mapUnFollowUserOnPressedToState(
    String uid,
  ) async* {
    yield FollowButtonState(inProgress: true);
    try {
      await _userRepository.unFollowUser(uid);
      _usersProvider.unFollow(uid: uid); // フォロワー数を-1する
      await _followingProvider.reload();
      showSnackBar(context, 'フォローを解除しました');
      yield FollowButtonState(inProgress: false);
    } on Exception catch (e) {
      debugPrint(e.toString());
      showSnackBar(context, 'エラーが発生しました');
      yield FollowButtonState(inProgress: false);
    }
  }
}
