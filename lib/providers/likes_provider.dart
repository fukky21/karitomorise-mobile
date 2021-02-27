import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../repositories/index.dart';

class LikesProvider with ChangeNotifier {
  LikesProvider({@required this.context}) {
    _authRepository = context.read<FirebaseAuthenticationRepository>();
    _userRepository = context.read<FirebaseUserRepository>();
    _init();
  }

  final BuildContext context;
  FirebaseAuthenticationRepository _authRepository;
  FirebaseUserRepository _userRepository;
  List<String> _likes;

  List<String> get likes => _likes;

  Future<void> reload() async {
    final currentUser = _authRepository.getCurrentUser();
    if (currentUser != null) {
      final likes = await _userRepository.getLikes(currentUser.uid);
      _likes = likes;
      notifyListeners();
    } else {
      _likes = [];
      notifyListeners();
    }
  }

  Future<void> _init() async {
    await reload();
  }
}
