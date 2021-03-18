import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../providers/index.dart';
import '../../repositories/index.dart';
import 'search_result_screen_event.dart';
import 'search_result_screen_state.dart';

class SearchResultScreenBloc
    extends Bloc<SearchResultScreenEvent, SearchResultScreenState> {
  SearchResultScreenBloc({@required this.context}) : super(null) {
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
  String _keyword;
  List<String> _eventIdsByKeywords;
  QueryDocumentSnapshot _lastVisible;
  bool _fetching = false;

  @override
  Stream<SearchResultScreenState> mapEventToState(
    SearchResultScreenEvent event,
  ) async* {
    if (event is Initialized) {
      yield* _mapInitializedToState(event.keyword);
    }
    if (event is Fetched) {
      yield* _mapFetchedToState();
    }
  }

  Stream<SearchResultScreenState> _mapInitializedToState(
    String keyword,
  ) async* {
    yield null; // Refresh時に中央にインジケータを表示するためにnullを渡す
    _eventIds = [];
    _keyword = keyword;
    _eventIdsByKeywords = null;
    _lastVisible = null;
    try {
      yield await _fetch();
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }

  Stream<SearchResultScreenState> _mapFetchedToState() async* {
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

  Future<SearchResultScreenState> _fetch() async {
    if (_eventIdsByKeywords == null) {
      final keywords = <String>[];
      // 半角/全角スペースで文字列を分割する
      _keyword.split(RegExp(r' |　')).forEach(
        (keyword) {
          if (keyword.isNotEmpty) {
            keywords.add(keyword.toLowerCase()); // 例: [リオレウス, リオレイア]
          }
        },
      );
      _eventIdsByKeywords =
          await _eventRepository.getEventIdsByKeywords(keywords);
    }
    final response = await _eventRepository.find(
      EventQuery(
        keyword: _keyword,
        eventIds: _eventIdsByKeywords,
        lastVisible: _lastVisible,
        limit: 10,
      ),
    );
    _lastVisible = response.lastVisible;
    final events = response.events;
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
    return SearchResultScreenState(
      eventIds: _eventIds,
      isFetchabled: isFetchable,
    );
  }
}
