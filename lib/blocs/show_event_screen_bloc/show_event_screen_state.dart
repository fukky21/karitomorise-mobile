import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:karitomorise/models/event_comment.dart';

abstract class ShowEventScreenState extends Equatable {
  @override
  List<Object> get props => const [];
}

class InitializeInProgress extends ShowEventScreenState {}

class InitializeSuccess extends ShowEventScreenState {
  InitializeSuccess({@required this.comments});

  final List<EventComment> comments;
}

class InitializeFailure extends ShowEventScreenState {}
