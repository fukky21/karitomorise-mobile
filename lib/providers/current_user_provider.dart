import 'dart:async';

import 'package:flutter/material.dart';

import '../models/index.dart';
import '../repositories/index.dart';

class CurrentUserProvider with ChangeNotifier {
  CurrentUserProvider({
    @required FirebaseAuthenticationRepository authRepository,
  }) {
    _authRepository = authRepository;
    _init();
  }

  FirebaseAuthenticationRepository _authRepository;
  StreamSubscription _subscription;
  CurrentUser _currentUser;

  CurrentUser get currentUser => _currentUser;

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _init() async {
    try {
      await _subscription?.cancel();
      _subscription =
          _authRepository.getAuthStateChanges().listen((user) async {
        if (user == null) {
          _currentUser = null;
        } else {
          _currentUser = CurrentUser(
            uid: user.uid,
            email: user.email,
            createdAt: user.metadata.creationTime,
            updatedAt: user.metadata.lastSignInTime,
          );
        }
        notifyListeners();
      });
    } on Exception catch (e) {
      debugPrint(e.toString());
      _currentUser = null;
      notifyListeners();
    }
  }
}
