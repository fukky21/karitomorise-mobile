import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../repositories/firebase_authentication_repository.dart';

class EditEmailViewModel with ChangeNotifier {
  final _authRepository = FirebaseAuthenticationRepository();

  EditEmailScreenState _state = EditEmailScreenLoading();

  EditEmailScreenState getState() {
    return _state;
  }

  void init() {
    _state = EditEmailScreenLoading();
    notifyListeners();

    try {
      final currentUser = _authRepository.getCurrentUser();
      if (currentUser.isAnonymous) {
        _state = EditEmailScreenLoadFailure();
        notifyListeners();
      } else {
        _state = EditEmailScreenLoadSuccess(email: currentUser.email);
        notifyListeners();
      }
    } on Exception catch (e) {
      debugPrint(e.toString());
      _state = EditEmailScreenLoadFailure();
      notifyListeners();
    }
  }

  Future<void> updateEmail({
    @required String newEmail,
    @required String password,
  }) async {
    _state = UpdateEmailInProgress();
    notifyListeners();

    try {
      await _authRepository.updateEmail(newEmail: newEmail, password: password);
      _state = UpdateEmailSuccess();
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      debugPrint(e.code);
      if (e.code == 'invalid-email') {
        _state = UpdateEmailFailure(
          type: UpdateEmailFailureType.invalidEmail,
        );
      } else if (e.code == 'wrong-password') {
        _state = UpdateEmailFailure(
          type: UpdateEmailFailureType.wrongPassword,
        );
      } else if (e.code == 'email-already-in-use') {
        _state = UpdateEmailFailure(
          type: UpdateEmailFailureType.emailAlreadyInUse,
        );
      } else {
        _state = UpdateEmailFailure(type: UpdateEmailFailureType.other);
      }
      notifyListeners();
    } on Exception catch (e) {
      debugPrint(e.toString());
      _state = UpdateEmailFailure(type: UpdateEmailFailureType.other);
      notifyListeners();
    }
  }
}

abstract class EditEmailScreenState extends Equatable {
  @override
  List<Object> get props => const [];
}

class EditEmailScreenLoading extends EditEmailScreenState {}

class EditEmailScreenLoadSuccess extends EditEmailScreenState {
  EditEmailScreenLoadSuccess({@required this.email});

  final String email;
}

class EditEmailScreenLoadFailure extends EditEmailScreenState {}

class UpdateEmailInProgress extends EditEmailScreenState {}

class UpdateEmailSuccess extends EditEmailScreenState {}

class UpdateEmailFailure extends EditEmailScreenState {
  UpdateEmailFailure({@required this.type});

  final UpdateEmailFailureType type;
}

enum UpdateEmailFailureType {
  invalidEmail,
  wrongPassword,
  emailAlreadyInUse,
  other,
}
