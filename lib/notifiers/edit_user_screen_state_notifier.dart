import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../models/index.dart';
import '../repositories/index.dart';

class EditUserScreenStateNotifier with ChangeNotifier {
  EditUserScreenStateNotifier({@required this.userRepository});

  EditUserScreenState state;
  final FirebaseUserRepository userRepository;

  Future<void> updateUser({
    @required String name,
    @required AppUserAvatar avatar,
  }) async {
    state = UpdateUserInProgress();
    notifyListeners();

    try {
      await userRepository.updateUser(name: name, avatar: avatar);
      state = UpdateUserSuccess();
      notifyListeners();
    } on Exception catch (e) {
      debugPrint(e.toString());
      state = UpdateUserFailure();
      notifyListeners();
    }
  }
}

abstract class EditUserScreenState extends Equatable {
  @override
  List<Object> get props => const [];
}

class UpdateUserInProgress extends EditUserScreenState {}

class UpdateUserSuccess extends EditUserScreenState {}

class UpdateUserFailure extends EditUserScreenState {}
