import 'package:equatable/equatable.dart';

abstract class ShowEventScreenState extends Equatable {
  @override
  List<Object> get props => const [];
}

class InitializeInProgress extends ShowEventScreenState {}

class InitializeSuccess extends ShowEventScreenState {}

class InitializeFailure extends ShowEventScreenState {}
