import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repositories/index.dart';
import 'search_tab_event.dart';
import 'search_tab_state.dart';

class SearchTabBloc extends Bloc<SearchTabEvent, SearchTabState> {
  SearchTabBloc({@required this.context}) : super(null) {
    _publicRepository = context.read<FirebasePublicRepository>();
  }

  final BuildContext context;
  FirebasePublicRepository _publicRepository;

  @override
  Stream<SearchTabState> mapEventToState(SearchTabEvent event) async* {
    if (event is Initialized) {
      yield* _mapInitializedToState();
    }
  }

  Stream<SearchTabState> _mapInitializedToState() async* {
    yield InitializeInProgress();
    try {
      final hotwords = await _publicRepository.getHotwords();
      yield InitializeSuccess(hotwords: hotwords);
    } on Exception catch (e) {
      debugPrint(e.toString());
      yield InitializeFailure();
    }
  }
}
