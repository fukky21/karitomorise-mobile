import 'package:flutter/material.dart';

import '../../repositories/firebase_authentication_repository.dart';
import '../../repositories/firebase_messaging_repository.dart';
import '../../repositories/firebase_user_repository.dart';

class MypageViewModel with ChangeNotifier {
  final _authRepository = FirebaseAuthenticationRepository();
  final _messagingRepository = FirebaseMessagingRepository();
  final _userRepository = FirebaseUserRepository();

  MypageScreenState _state = MypageScreenState(loading: false);

  MypageScreenState getState() {
    return _state;
  }

  Future<void> signOut() async {
    _state = MypageScreenState(loading: true);
    notifyListeners();

    try {
      // サインアウト前にトークンを削除する
      final token = await _messagingRepository.getToken();
      await _userRepository.removeToken(token: token);

      // 匿名でサインインし直す
      await _authRepository.signInAnonymously();
    } on Exception catch (e) {
      debugPrint(e.toString());
    }

    _state = MypageScreenState(loading: false);
    notifyListeners();
  }
}

class MypageScreenState {
  MypageScreenState({@required this.loading});

  final bool loading;
}
