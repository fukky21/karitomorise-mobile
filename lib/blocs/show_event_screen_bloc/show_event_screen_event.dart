import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class ShowEventScreenEvent extends Equatable {
  @override
  List<Object> get props => const [];
}

class Initialized extends ShowEventScreenEvent {
  Initialized({@required this.eventId});

  final String eventId;
}
