import 'package:equatable/equatable.dart';

abstract class ShowUserScreenState extends Equatable {
  @override
  List<Object> get props => const [];
}

class InitializeInProgress extends ShowUserScreenState {}

class InitializeSuccess extends ShowUserScreenState {}

class InitializeFailure extends ShowUserScreenState {}
