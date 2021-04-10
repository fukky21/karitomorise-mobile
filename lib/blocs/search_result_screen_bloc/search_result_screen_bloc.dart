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

  @override
  Stream<SearchResultScreenState> mapEventToState(
    SearchResultScreenEvent event,
  ) async* {
    if (event is Initialized) {
      yield* _mapInitializedToState(event.keyword);
    }
  }

  Stream<SearchResultScreenState> _mapInitializedToState(
    String keyword,
  ) async* {
    yield SearchInProgress();
    try {
      final events = await _eventRepository.getEventsByKeyword(keyword);
      for (final event in events) {
        _eventsProvider.add(event: event);
        if (event?.uid != null) {
          final user = await _userRepository.getUser(event.uid);
          if (user != null) {
            _usersProvider.add(user: user);
          }
        }
      }
      yield SearchSuccess(events: events);
    } on Exception catch (e) {
      debugPrint(e.toString());
      yield SearchFailure();
    }
  }
}
