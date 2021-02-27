import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../providers/index.dart';
import '../../repositories/index.dart';
import 'show_event_screen_event.dart';
import 'show_event_screen_state.dart';

class ShowEventScreenBloc
    extends Bloc<ShowEventScreenEvent, ShowEventScreenState> {
  ShowEventScreenBloc({@required this.context}) : super(null) {
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
  Stream<ShowEventScreenState> mapEventToState(
    ShowEventScreenEvent event,
  ) async* {
    if (event is Initialized) {
      yield* _mapInitializedToState(event.eventId);
    }
  }

  Stream<ShowEventScreenState> _mapInitializedToState(String eventId) async* {
    yield InitializeInProgress();
    try {
      final event = await _eventRepository.getEvent(eventId);
      if (event == null) {
        _eventsProvider.remove(eventId: eventId);
        yield InitializeFailure();
      } else {
        _eventsProvider.add(event: event);
        final user = await _userRepository.getUser(event.uid);
        _usersProvider.add(user: user);
        yield InitializeSuccess();
      }
    } on Exception catch (e) {
      debugPrint(e.toString());
      yield InitializeFailure();
    }
  }
}
