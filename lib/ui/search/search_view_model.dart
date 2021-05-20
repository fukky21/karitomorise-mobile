import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../repositories/firebase_public_repository.dart';

class SearchViewModel with ChangeNotifier {
  final _publicRepository = FirebasePublicRepository();

  SearchScreenState _state = SearchScreenLoading();

  SearchScreenState getState() {
    return _state;
  }

  Future<void> init() async {
    _state = SearchScreenLoading();
    notifyListeners();

    try {
      final hotwords = await _publicRepository.getHotwords();
      _state = SearchScreenLoadSuccess(hotwords: hotwords);
      notifyListeners();
    } on Exception catch (e) {
      debugPrint(e.toString());
      _state = SearchScreenLoadFailure();
      notifyListeners();
    }
  }
}

abstract class SearchScreenState extends Equatable {
  @override
  List<Object> get props => const [];
}

class SearchScreenLoading extends SearchScreenState {}

class SearchScreenLoadSuccess extends SearchScreenState {
  SearchScreenLoadSuccess({@required this.hotwords});

  final List<String> hotwords;
}

class SearchScreenLoadFailure extends SearchScreenState {}
