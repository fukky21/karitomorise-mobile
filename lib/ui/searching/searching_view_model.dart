import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class SearchingViewModel with ChangeNotifier {
  SearchingScreenState _state = SearchingScreenLoading();

  SearchingScreenState getState() {
    return _state;
  }

  Future<void> init() async {
    _state = SearchingScreenLoading();
    notifyListeners();

    try {
      // TODO(fukky21): 検索履歴を取得する
      await Future<void>.delayed(const Duration(seconds: 2));
      _state = SearchingScreenLoadSuccess();
      notifyListeners();
    } on Exception catch (e) {
      debugPrint(e.toString());
      _state = SearchingScreenLoadFailure();
      notifyListeners();
    }
  }
}

abstract class SearchingScreenState extends Equatable {
  @override
  List<Object> get props => const [];
}

class SearchingScreenLoading extends SearchingScreenState {}

class SearchingScreenLoadSuccess extends SearchingScreenState {}

class SearchingScreenLoadFailure extends SearchingScreenState {}
