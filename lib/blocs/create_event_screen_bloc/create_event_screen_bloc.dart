import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/index.dart';
import '../../repositories/index.dart';
import 'create_event_screen_event.dart';
import 'create_event_screen_state.dart';

class CreateEventScreenBloc
    extends Bloc<CreateEventScreenEvent, CreateEventScreenState> {
  CreateEventScreenBloc({@required this.context}) : super(null) {
    _eventRepository = context.read<FirebaseEventRepository>();
  }

  final BuildContext context;
  FirebaseEventRepository _eventRepository;

  @override
  Stream<CreateEventScreenState> mapEventToState(
    CreateEventScreenEvent event,
  ) async* {
    if (event is CreateEventOnPressed) {
      yield* _mapCreateEventOnPressedToState(event.event);
    }
  }

  Stream<CreateEventScreenState> _mapCreateEventOnPressedToState(
    AppEvent event,
  ) async* {
    yield CreateEventInProgress();
    try {
      await _eventRepository.createEvent(event);
      yield CreateEventSuccess();
    } on Exception catch (e) {
      debugPrint(e.toString());
      yield CreateEventFailure();
    }
  }
}
