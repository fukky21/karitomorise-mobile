import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../repositories/index.dart';

class SearchTabStateNotifier with ChangeNotifier {
  SearchTabStateNotifier({@required this.publicRepository}) {
    init();
  }

  final FirebasePublicRepository publicRepository;
  SearchTabState state = SearchTabLoading();

  Future<void> init() async {
    state = SearchTabLoading();
    notifyListeners();

    try {
      final hotwords = await publicRepository.getHotwords();
      state = SearchTabLoadSuccess(hotwords: hotwords);
      notifyListeners();
    } on Exception catch (e) {
      debugPrint(e.toString());
      state = SearchTabLoadFailure();
      notifyListeners();
    }
  }
}

abstract class SearchTabState extends Equatable {
  @override
  List<Object> get props => const [];
}

class SearchTabLoading extends SearchTabState {}

class SearchTabLoadSuccess extends SearchTabState {
  SearchTabLoadSuccess({@required this.hotwords});

  final List<String> hotwords;
}

class SearchTabLoadFailure extends SearchTabState {}
