import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../repositories/index.dart';

class FavoritesProvider with ChangeNotifier {
  FavoritesProvider({@required this.context}) {
    _authRepository = context.read<FirebaseAuthenticationRepository>();
    _userRepository = context.read<FirebaseUserRepository>();
    _init();
  }

  final BuildContext context;
  FirebaseAuthenticationRepository _authRepository;
  FirebaseUserRepository _userRepository;
  List<String> _favorites;

  List<String> get favorites => _favorites;

  Future<void> reload() async {
    final currentUser = _authRepository.getCurrentUser();
    if (currentUser != null) {
      final favorites = await _userRepository.getFavorites(currentUser.uid);
      _favorites = favorites;
      notifyListeners();
    } else {
      _favorites = [];
      notifyListeners();
    }
  }

  Future<void> _init() async {
    await reload();
  }
}
