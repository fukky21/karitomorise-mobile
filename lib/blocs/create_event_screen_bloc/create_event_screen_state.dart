import 'package:equatable/equatable.dart';

abstract class CreateEventScreenState extends Equatable {
  @override
  List<Object> get props => const [];
}

class CreateEventInProgress extends CreateEventScreenState {}

class CreateEventSuccess extends CreateEventScreenState {}

class CreateEventFailure extends CreateEventScreenState {}
