import 'package:equatable/equatable.dart';

abstract class CurrentUserEvent extends Equatable {
  @override
  List<Object> get props => const [];
}

class ListenStarted extends CurrentUserEvent {}

class Listened extends CurrentUserEvent {}

class ListenStopped extends CurrentUserEvent {}
