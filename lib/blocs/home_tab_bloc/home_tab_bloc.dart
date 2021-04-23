import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/index.dart';
import '../../providers/index.dart';
import '../../repositories/index.dart';
import 'home_tab_event.dart';
import 'home_tab_state.dart';

class SearchTabBloc extends Bloc<SearchTabEvent, SearchTabState> {
  SearchTabBloc({@required this.context}) : super(null) {
    _userRepository = context.read<FirebaseUserRepository>();
    _eventRepository = context.read<FirebaseEventRepository>();
    _usersProvider = context.read<UsersProvider>();
    _eventsProvider = context.read<EventsProvider>();
  }

  final BuildContext context;
  FirebaseUserRepository _userRepository;
  FirebaseEventRepository _eventRepository;
  UsersProvider _usersProvider;
  EventsProvider _eventsProvider;
  List<String> _eventIds;
  QueryDocumentSnapshot _lastVisible;
  bool _fetching = false;

  @override
  Stream<SearchTabState> mapEventToState(SearchTabEvent event) async* {
    if (event is Initialized) {
      yield* _mapInitializedToState();
    }
    if (event is Fetched) {
      yield* _mapFetchedToState();
    }
  }

  Stream<SearchTabState> _mapInitializedToState() async* {
    yield null; // Refresh時に中央にインジケータを表示するためにnullを渡す
    _eventIds = [];
    _lastVisible = null;
    try {
      yield await _fetch();
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }

  Stream<SearchTabState> _mapFetchedToState() async* {
    if (!_fetching) {
      _fetching = true; // 重複してFetchしないようにする
      try {
        yield await _fetch();
      } on Exception catch (e) {
        debugPrint(e.toString());
      }
      _fetching = false;
    }
  }

  Future<SearchTabState> _fetch() async {
    final response = await _eventRepository.getNewEvents(
      lastVisible: _lastVisible,
    );
    _lastVisible = response['last_visible'] as QueryDocumentSnapshot;
    final events = response['events'] as List<AppEvent>;
    var isFetchable = true;
    for (final event in events) {
      if (!_eventIds.contains(event.id)) {
        // 未追加の場合は追加する
        _eventIds.add(event.id);
        _eventsProvider.add(event: event);
        if (event?.uid != null) {
          final user = await _userRepository.getUser(event.uid);
          if (user != null) {
            _usersProvider.add(user: user);
          }
        }
      } else {
        // すでに追加されている場合は最後まで取得したと判断する
        isFetchable = false;
      }
    }
    return SearchTabState(eventIds: _eventIds, isFetchabled: isFetchable);
  }
}
