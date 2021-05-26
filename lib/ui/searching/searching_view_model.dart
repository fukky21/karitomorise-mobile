import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../repositories/shared_preference_repository.dart';

class SearchingViewModel with ChangeNotifier {
  final _prefRepository = SharedPreferenceRepository();

  SearchingScreenState _state = SearchingScreenLoading();

  SearchingScreenState getState() {
    return _state;
  }

  Future<void> init() async {
    _state = SearchingScreenLoading();
    notifyListeners();

    try {
      final histories = await _prefRepository.getSearchHistories();
      _state = SearchingScreenLoadSuccess(histories: histories);
      notifyListeners();
    } on Exception catch (e) {
      debugPrint(e.toString());
      _state = SearchingScreenLoadFailure();
      notifyListeners();
    }
  }

  Future<void> deleteSearchKeyword({@required String keyword}) async {
    await _prefRepository.deleteSearchKeyword(keyword: keyword);
    await init();
  }
}

abstract class SearchingScreenState extends Equatable {
  @override
  List<Object> get props => const [];
}

class SearchingScreenLoading extends SearchingScreenState {}

class SearchingScreenLoadSuccess extends SearchingScreenState {
  SearchingScreenLoadSuccess({@required this.histories});

  final List<String> histories;
}

class SearchingScreenLoadFailure extends SearchingScreenState {}
