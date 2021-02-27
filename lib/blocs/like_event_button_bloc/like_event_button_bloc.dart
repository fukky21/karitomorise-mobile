import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../providers/index.dart';
import '../../repositories/index.dart';
import 'like_event_button_event.dart';
import 'like_event_button_state.dart';

class LikeEventButtonBloc
    extends Bloc<LikeEventButtonEvent, LikeEventButtonState> {
  LikeEventButtonBloc({@required this.context}) : super(null) {
    _userRepository = context.read<FirebaseUserRepository>();
    _likesProvider = context.read<LikesProvider>();
  }

  final BuildContext context;
  FirebaseUserRepository _userRepository;
  LikesProvider _likesProvider;

  @override
  Stream<LikeEventButtonState> mapEventToState(
    LikeEventButtonEvent event,
  ) async* {
    if (event is LikeEventOnPressed) {
      yield* _mapLikeEventOnPressedToState(event.eventId);
    }
    if (event is UnLikeEventOnPressed) {
      yield* _mapUnLikeEventOnPressedToState(event.eventId);
    }
  }

  Stream<LikeEventButtonState> _mapLikeEventOnPressedToState(
    String eventId,
  ) async* {
    yield LikeEventButtonState(inProgress: true);
    try {
      await _userRepository.likeEvent(eventId);
      await _likesProvider.reload();
      yield LikeEventButtonState(inProgress: false);
    } on Exception catch (e) {
      debugPrint(e.toString());
      yield LikeEventButtonState(inProgress: false);
    }
  }

  Stream<LikeEventButtonState> _mapUnLikeEventOnPressedToState(
    String eventId,
  ) async* {
    yield LikeEventButtonState(inProgress: true);
    try {
      await _userRepository.unLikeEvent(eventId);
      await _likesProvider.reload();
      yield LikeEventButtonState(inProgress: false);
    } on Exception catch (e) {
      debugPrint(e.toString());
      yield LikeEventButtonState(inProgress: false);
    }
  }
}
