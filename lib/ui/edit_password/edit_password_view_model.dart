import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../repositories/firebase_authentication_repository.dart';

class EditPasswordViewModel with ChangeNotifier {
  final _authRepository = FirebaseAuthenticationRepository();
  EditPasswordScreenState _state;

  EditPasswordScreenState getState() {
    return _state;
  }

  Future<void> updatePassword({
    @required String currentPassword,
    @required String newPassword,
  }) async {
    _state = UpdatePasswordInProgress();
    notifyListeners();

    try {
      await _authRepository.updatePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      _state = UpdatePasswordSuccess();
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      debugPrint(e.code);
      if (e.code == 'wrong-password') {
        _state = UpdatePasswordFailure(
          type: UpdatePasswordFailureType.wrongPassword,
        );
      } else if (e.code == 'weak-password') {
        _state = UpdatePasswordFailure(
          type: UpdatePasswordFailureType.weakPassword,
        );
      } else {
        _state = UpdatePasswordFailure(type: UpdatePasswordFailureType.other);
      }
      notifyListeners();
    } on Exception catch (e) {
      debugPrint(e.toString());
      _state = UpdatePasswordFailure(type: UpdatePasswordFailureType.other);
      notifyListeners();
    }
  }
}

abstract class EditPasswordScreenState extends Equatable {
  @override
  List<Object> get props => const [];
}

class UpdatePasswordInProgress extends EditPasswordScreenState {}

class UpdatePasswordSuccess extends EditPasswordScreenState {}

class UpdatePasswordFailure extends EditPasswordScreenState {
  UpdatePasswordFailure({@required this.type});

  final UpdatePasswordFailureType type;
}

enum UpdatePasswordFailureType { wrongPassword, weakPassword, other }
