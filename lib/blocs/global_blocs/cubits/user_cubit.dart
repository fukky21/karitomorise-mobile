import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/index.dart';
import '../../../repositories/index.dart';

class UserCubit extends Cubit<AppUser> {
  UserCubit() : super(null);

  final _authRepository = FirebaseAuthenticationRepository();
  final _userRepository = FirebaseUserRepository();

  Future<void> load() async {
    try {
      final currentUser = _authRepository.getCurrentUser();
      final user = await _userRepository.getUser(currentUser.uid);
      emit(user);
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }
}
