import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class ShowUserScreenEvent extends Equatable {
  @override
  List<Object> get props => const [];
}

class Initialized extends ShowUserScreenEvent {
  Initialized({@required this.uid});

  final String uid;
}
