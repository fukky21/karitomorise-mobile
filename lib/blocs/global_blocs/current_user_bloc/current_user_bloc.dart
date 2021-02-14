import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../repositories/index.dart';
import 'current_user_event.dart';
import 'current_user_state.dart';

class CurrentUserBloc extends Bloc<CurrentUserEvent, CurrentUserState> {
  CurrentUserBloc() : super(null);

  final _authRepository = FirebaseAuthenticationRepository();
  final _userRepository = FirebaseUserRepository();
  StreamSubscription _subscription1;
  StreamSubscription _subscription2;
  DocumentSnapshot _doc;
  DocumentSnapshot _subDoc;

  @override
  Future<void> close() {
    _subscription1?.cancel();
    _subscription2?.cancel();
    return super.close();
  }

  @override
  Stream<CurrentUserState> mapEventToState(CurrentUserEvent event) async* {
    if (event is ListenStarted) {
      yield* _mapListenStartedToState();
    }
    if (event is Listened) {
      yield* _mapListenedToState();
    }
    if (event is ListenStopped) {
      yield* _mapListenStoppedToState();
    }
  }

  Stream<CurrentUserState> _mapListenStartedToState() async* {
    try {
      final currentUser = _authRepository.getCurrentUser();
      if (currentUser != null) {
        await _subscription1?.cancel();
        await _subscription2?.cancel();
        _subscription1 =
            _userRepository.getDocumentSnapshots(currentUser.uid).listen(
          (doc) {
            _doc = doc;
            add(Listened());
          },
        );
        _subscription2 =
            _userRepository.getSubDocumentSnapshots(currentUser.uid).listen(
          (doc) {
            _subDoc = doc;
            add(Listened());
          },
        );
      }
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }

  Stream<CurrentUserState> _mapListenedToState() async* {
    try {
      if (_doc != null && _subDoc != null) {
        final user = _userRepository.getUserFromDocuments(_doc, _subDoc);
        final likedEvents = _userRepository.getLikesFromDocument(_doc);
        yield CurrentUserState(user: user, likedEvents: likedEvents);
      }
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }

  Stream<CurrentUserState> _mapListenStoppedToState() async* {
    await _subscription1?.cancel();
    await _subscription2?.cancel();
    _doc = null;
    _subDoc = null;
    yield null;
  }
}
