import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../repositories/index.dart';

class FollowingProvider with ChangeNotifier {
  FollowingProvider({@required this.context}) {
    _authRepository = context.read<FirebaseAuthenticationRepository>();
    _userRepository = context.read<FirebaseUserRepository>();
    _init();
  }

  final BuildContext context;
  FirebaseAuthenticationRepository _authRepository;
  FirebaseUserRepository _userRepository;
  List<String> _following;

  List<String> get following => _following;

  Future<void> reload() async {
    final currentUser = _authRepository.getCurrentUser();
    if (currentUser != null) {
      final following = await _userRepository.getFollowing(currentUser.uid);
      _following = following;
      notifyListeners();
    } else {
      _following = [];
      notifyListeners();
    }
  }

  Future<void> _init() async {
    await reload();
  }
}
