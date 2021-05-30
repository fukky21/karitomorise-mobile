import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../repositories/shared_preference_repository.dart';

class StartViewModel with ChangeNotifier {
  final _prefRepository = SharedPreferenceRepository();

  StartScreenState _state = StartScreenLoading();

  StartScreenState getState() {
    return _state;
  }

  Future<void> init() async {
    _state = StartScreenLoading();
    notifyListeners();

    try {
      final isFirstLaunchFinished =
          await _prefRepository.checkIsFirstLaunchFinished();
      _state = StartScreenLoadSuccess(
        isFirstLaunchFinished: isFirstLaunchFinished,
      );
      notifyListeners();
    } on Exception catch (e) {
      debugPrint(e.toString());
      _state = StartScreenLoadFailure();
      notifyListeners();
    }
  }
}

abstract class StartScreenState extends Equatable {
  @override
  List<Object> get props => const [];
}

class StartScreenLoading extends StartScreenState {}

class StartScreenLoadSuccess extends StartScreenState {
  StartScreenLoadSuccess({@required this.isFirstLaunchFinished});

  final bool isFirstLaunchFinished;
}

class StartScreenLoadFailure extends StartScreenState {}
