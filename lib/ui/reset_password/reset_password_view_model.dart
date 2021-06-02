import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../repositories/firebase_authentication_repository.dart';

class ResetPasswordViewModel with ChangeNotifier {
  final _authRepository = FirebaseAuthenticationRepository();

  ResetPasswordScreenState _state;

  ResetPasswordScreenState getState() {
    return _state;
  }

  Future<void> sendPasswordResetEmail({@required String email}) async {
    _state = SendPasswordResetEmailInProgress();
    notifyListeners();

    try {
      await _authRepository.sendPasswordResetEmail(email: email);
      _state = SendPasswordResetEmailSuccess();
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      debugPrint(e.code);
      if (e.code == 'invalid-email') {
        _state = SendPasswordResetEmailFailure(
          type: SendPasswordResetEmailFailureType.invalidEmail,
        );
      } else if (e.code == 'user-not-found') {
        _state = SendPasswordResetEmailFailure(
          type: SendPasswordResetEmailFailureType.userNotFound,
        );
      } else {
        _state = SendPasswordResetEmailFailure(
          type: SendPasswordResetEmailFailureType.other,
        );
      }
      notifyListeners();
    } on Exception catch (e) {
      debugPrint(e.toString());
      _state = SendPasswordResetEmailFailure(
        type: SendPasswordResetEmailFailureType.other,
      );
      notifyListeners();
    }
  }
}

abstract class ResetPasswordScreenState extends Equatable {
  @override
  List<Object> get props => const [];
}

class SendPasswordResetEmailInProgress extends ResetPasswordScreenState {}

class SendPasswordResetEmailSuccess extends ResetPasswordScreenState {}

class SendPasswordResetEmailFailure extends ResetPasswordScreenState {
  SendPasswordResetEmailFailure({@required this.type});

  final SendPasswordResetEmailFailureType type;
}

enum SendPasswordResetEmailFailureType { invalidEmail, userNotFound, other }
