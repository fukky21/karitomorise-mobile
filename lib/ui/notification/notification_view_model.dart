import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../repositories/firebase_notification_repository.dart';

class NotificationViewModel with ChangeNotifier {
  final _notificationRepository = FirebaseNotificationRepository();

  NotificationScreenState _state = NotificationScreenLoading();

  NotificationScreenState getState() {
    return _state;
  }

  Future<void> init() async {
    _state = NotificationScreenLoading();
    notifyListeners();

    try {
      final stream = _notificationRepository.getPostNumberStream();
      if (stream != null) {
        _state = NotificationScreenLoadSuccess(stream: stream);
        notifyListeners();
      } else {
        _state = NotificationScreenLoadFailure();
        notifyListeners();
      }
    } on Exception catch (e) {
      debugPrint(e.toString());
      _state = NotificationScreenLoadFailure();
      notifyListeners();
    }
  }
}

abstract class NotificationScreenState extends Equatable {
  @override
  List<Object> get props => const [];
}

class NotificationScreenLoading extends NotificationScreenState {}

class NotificationScreenLoadSuccess extends NotificationScreenState {
  NotificationScreenLoadSuccess({@required this.stream});

  final Stream<List<int>> stream;
}

class NotificationScreenLoadFailure extends NotificationScreenState {}
