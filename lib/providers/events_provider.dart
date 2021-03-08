import 'package:flutter/material.dart';

import '../models/index.dart';

class EventsProvider with ChangeNotifier {
  EventsProvider() {
    _init();
  }

  Map<String, AppEvent> _eventList;

  AppEvent get({String eventId}) {
    if (eventId != null) {
      return _eventList[eventId];
    }
    return null;
  }

  void add({AppEvent event}) {
    if (event != null && event.id != null) {
      _eventList[event.id] = event;
      notifyListeners();
    }
  }

  void remove({String eventId}) {
    _eventList[eventId] = null;
    notifyListeners();
  }

  void changeCommentCount({String eventId, int count}) {
    if (eventId != null) {
      final event = _eventList[eventId];
      if (event != null) {
        event.commentCount = count;
        add(event: event);
      }
    }
  }

  Future<void> _init() async {
    _eventList = {};
    notifyListeners();
  }
}
