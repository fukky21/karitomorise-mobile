import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../repositories/index.dart';

class FollowingCubit extends Cubit<List<String>> {
  FollowingCubit() : super([]);

  final _authRepository = FirebaseAuthenticationRepository();
  final _userRepository = FirebaseUserRepository();

  Future<void> load() async {
    try {
      final currentUser = _authRepository.getCurrentUser();
      final following = await _userRepository.getFollowing(currentUser.uid);
      emit(following);
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }
}
