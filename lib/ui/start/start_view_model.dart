import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../repositories/shared_preference_repository.dart';
import '../../store.dart';

class StartViewModel with ChangeNotifier {
  StartViewModel({@required this.store});

  final Store store;
  final _prefRepository = SharedPreferenceRepository();

  StartScreenState _state = StartScreenLoading();

  StartScreenState getState() {
    return _state;
  }

  Future<void> init() async {
    _state = StartScreenLoading();
    notifyListeners();

    try {
      final isFirstLaunched = await _prefRepository.isFirstLaunched();
      final blockList = await _prefRepository.getBlockList();
      store.setBlockList(blockList);
      _state = StartScreenLoadSuccess(isFirstLaunched: isFirstLaunched);
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
  StartScreenLoadSuccess({@required this.isFirstLaunched});

  final bool isFirstLaunched;
}

class StartScreenLoadFailure extends StartScreenState {}
