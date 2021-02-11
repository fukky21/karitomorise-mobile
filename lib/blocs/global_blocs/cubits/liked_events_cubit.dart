import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../repositories/index.dart';

class LikedEventsCubit extends Cubit<List<String>> {
  LikedEventsCubit() : super([]);

  final _authRepository = FirebaseAuthenticationRepository();
  final _userRepository = FirebaseUserRepository();

  Future<void> load() async {
    try {
      final currentUser = _authRepository.getCurrentUser();
      final likedEvents = await _userRepository.getLikes(currentUser.uid);
      emit(likedEvents);
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }
}
