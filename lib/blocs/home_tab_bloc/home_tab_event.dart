import 'package:equatable/equatable.dart';

abstract class HomeTabEvent extends Equatable {
  @override
  List<Object> get props => const [];
}

class Initialized extends HomeTabEvent {}

class Fetched extends HomeTabEvent {}
