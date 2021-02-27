import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class FollowUserButtonEvent extends Equatable {
  @override
  List<Object> get props => const [];
}

class FollowUserOnPressed extends FollowUserButtonEvent {
  FollowUserOnPressed({@required this.uid});

  final String uid;
}

class UnFollowUserOnPressed extends FollowUserButtonEvent {
  UnFollowUserOnPressed({@required this.uid});

  final String uid;
}
