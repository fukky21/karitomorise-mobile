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
      final hasAgreedToTermsOfService =
          await _prefRepository.hasAgreedToTermsOfService();
      final blockList = await _prefRepository.getBlockList();
      store.setBlockList(blockList);
      _state = StartScreenLoadSuccess(
          hasAgreedToTermsOfService: hasAgreedToTermsOfService);
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
  StartScreenLoadSuccess({@required this.hasAgreedToTermsOfService});

  final bool hasAgreedToTermsOfService;
}

class StartScreenLoadFailure extends StartScreenState {}
