import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/index.dart';
import '../../providers/index.dart';
import '../../repositories/index.dart';
import '../../widgets/components/index.dart';
import 'show_event_comments_screen_event.dart';
import 'show_event_comments_screen_state.dart';

class ShowEventCommentsScreenBloc
    extends Bloc<ShowEventCommentsScreenEvent, ShowEventCommentsScreenState> {
  ShowEventCommentsScreenBloc({@required this.context}) : super(null) {
    _userRepository = context.read<FirebaseUserRepository>();
    _eventCommentRepository = context.read<FirebaseEventCommentRepository>();
    _usersProvider = context.read<UsersProvider>();
    _eventsProvider = context.read<EventsProvider>();
  }

  final BuildContext context;
  FirebaseUserRepository _userRepository;
  FirebaseEventCommentRepository _eventCommentRepository;
  UsersProvider _usersProvider;
  EventsProvider _eventsProvider;
  StreamSubscription _subscription;
  String _eventId;
  List<String> _userIds;
  List<EventComment> _comments;

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }

  @override
  Stream<ShowEventCommentsScreenState> mapEventToState(
    ShowEventCommentsScreenEvent event,
  ) async* {
    if (event is Initialized) {
      yield* _mapInitializedToState(event.eventId);
    }
    if (event is Listened) {
      yield* _mapListenedToState();
    }
    if (event is CreateCommentOnPressed) {
      yield* _mapCreateCommentOnPressedToState(event.message);
    }
  }

  Stream<ShowEventCommentsScreenState> _mapInitializedToState(
    String eventId,
  ) async* {
    try {
      _eventId = eventId;
      _userIds = [];
      await _subscription?.cancel();
      _subscription = _eventCommentRepository.getSnapshots(_eventId).listen(
        (snapshot) async {
          _comments = [];
          for (final doc in snapshot.docs) {
            final comment =
                _eventCommentRepository.getEventCommentFromDocument(doc);
            _comments.add(comment);
            if (comment?.uid != null && !_userIds.contains(comment.uid)) {
              // まだ追加されていないユーザーなら追加する
              final user = await _userRepository.getUser(comment.uid);
              _usersProvider.add(user: user);
              _userIds.add(comment.uid);
            }
          }
          add(Listened());
        },
      );
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }

  Stream<ShowEventCommentsScreenState> _mapListenedToState() async* {
    _eventsProvider.changeCommentCount(
      eventId: _eventId,
      count: _comments.length,
    );
    yield ShowEventCommentsScreenState(comments: _comments);
  }

  Stream<ShowEventCommentsScreenState> _mapCreateCommentOnPressedToState(
    String message,
  ) async* {
    try {
      await _eventCommentRepository.createEventComment(_eventId, message);
    } on Exception catch (e) {
      debugPrint(e.toString());
      showSnackBar(context, 'エラーが発生しました');
    }
  }
}
